# Allow host-initiated SSH replies without opening guest access

[日本語・実施手順](HOST-SSH.ja.md) | [Current handoff](HANDOFF-2026-11-23.md) | [Start](README.md)

On 2026-11-23, both FreeBSD guests had working IPv4 addresses/routes and `sshd` listening on `*:22`, yet host TCP/22 probes timed out. Custom nftables input chains unconditionally dropped packets arriving from `vmbr1` and `vmbr2`, including replies to host-initiated SSH. A stopped `pve-firewall` and ACCEPT policies in iptables did not show these independent nftables rules.

The [runtime delta](nftables/host-ssh-replies.nft) inserts one rule in each existing input chain. Each requires the exact ingress bridge, guest source IPv4, host destination IPv4, TCP source port 22, `ct state established`, and **`ct direction reply`**. Original input drops, forward chains and NAT remain in place. Guest-initiated connections and inter-guest forwarding receive no new allowance. ICMP echo replies remain blocked; use TCP/22 to check this change.

## Prepare and review persistence candidates

As root on Proxmox, from this repository's root:

~~~sh
perl docs/cpan-testers/scripts/prepare-host-ssh.pl \
  --vm-id 151 --input /root/cpan151.nft --output /root/cpan151.nft.host-ssh.next
perl docs/cpan-testers/scripts/prepare-host-ssh.pl \
  --vm-id 152 --input /root/cpan152.nft --output /root/cpan152.nft.host-ssh.next
diff -u /root/cpan151.nft /root/cpan151.nft.host-ssh.next
diff -u /root/cpan152.nft /root/cpan152.nft.host-ssh.next
~~~

Each diff must add exactly one input rule before the existing drop. `diff` exit 1 means differences were found. The helper only creates private, exclusive candidates; it neither changes the originals nor invokes nftables. It rejects existing outputs, symlinks, already patched inputs and unexpected input-chain layouts. Forward/NAT bytes are preserved.

Back up both original configurations and record the resulting directory:

~~~sh
cpan_backup_dir=$(mktemp -d /root/cpan-host-ssh-backup.XXXXXX)
cp -p /root/cpan151.nft /root/cpan152.nft "$cpan_backup_dir/"
nft list ruleset > "$cpan_backup_dir/ruleset-before.nft"
printf 'Backup: %s\n' "$cpan_backup_dir"
~~~

## Apply the runtime delta once

~~~sh
nft -a list chain inet cpan151_filter input
nft -a list chain inet cpan152_filter input
nft --check --file docs/cpan-testers/nftables/host-ssh-replies.nft
~~~

Only proceed if the original input layout matches, neither `cpan-rescue-host-ssh-151` nor `cpan-rescue-host-ssh-152` exists yet, and syntax checking succeeds. Reconcile partial/already installed changes before proceeding. Apply once, then inspect that the original drops remain below the new rules:

~~~sh
nft --file docs/cpan-testers/nftables/host-ssh-replies.nft
nft -a list chain inet cpan151_filter input
nft -a list chain inet cpan152_filter input
timeout 5 nc -n -z -v -w 3 10.151.0.2 22
timeout 5 nc -n -z -v -w 3 10.152.0.2 22
~~~

Both host probes should connect. After confirming Guest Agent responsiveness, execute the following individually; all four guest TCP/22 attempts should fail:

~~~sh
timeout 12 qm guest exec 151 -- /usr/bin/nc -n -z -v -w 3 10.151.0.1 22
timeout 12 qm guest exec 152 -- /usr/bin/nc -n -z -v -w 3 10.152.0.1 22
timeout 12 qm guest exec 151 -- /usr/bin/nc -n -z -v -w 3 10.152.0.2 22
timeout 12 qm guest exec 152 -- /usr/bin/nc -n -z -v -w 3 10.151.0.2 22
~~~

Check `exited=1`, the **guest** `exitcode` and diagnostic output, not only the `qm` exit status. Missing `nc`, Guest Agent timeouts and PID-only replies do not prove isolation. Stop sending further Guest Agent commands if responsiveness becomes uncertain.

After reviewing backups, diffs and both positive/negative probes, install the candidates:

~~~sh
mv /root/cpan151.nft.host-ssh.next /root/cpan151.nft
mv /root/cpan152.nft.host-ssh.next /root/cpan152.nft
~~~

The existing enabled `cpan151-network.service` and `cpan152-network.service` call their corresponding `/usr/local/sbin/cpan*-network-up` scripts, which load these `/root/cpan*.nft` files when the tables are absent. They skip loading when both tables already exist, so restarting these services is not a live-rule reload. No service restart, VM reboot, smoker stop, global ruleset flush, or report submission is required here. Reboot persistence remains a separate real-host validation.

## Rollback and verification limits

List each input chain with `nft -a`, identify the exact added rule by its unique comment, and delete **only its current handle** using `nft delete rule inet cpan151_filter input handle HANDLE` (and the corresponding VM 152 chain). Restore each original persistent file from the recorded backup if installed. Never copy handle values from old output or flush the whole ruleset.

This establishes specific TCP/22 paths only. SSH authentication, host-key pinning, external service connectivity, complete protocol isolation and unattended report transfer still need separate validation. Do not put host or sender credentials on the smoker VM.

The [Perl regression tests](tests/prepare-host-ssh.t) check candidate handling and byte preservation. The [Linux namespace integration test](tests/host-ssh-network.sh) reproduces the initial SSH failure, then checks permitted SSH replies, blocked other ports/new guest connections/inter-guest access, and rebuilding from prepared persistent candidates. Run privileged integration tests only on a disposable CI runner:

~~~sh
prove -v docs/cpan-testers/tests/*.t
bash docs/cpan-testers/tests/host-ssh-network.sh
~~~

References: [nftables conntrack](https://wiki.nftables.org/wiki-nftables/index.php/Matching_connection_tracking_stateful_metainformation), [nftables syntax](https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes).
