# FreeBSD smoker operations / troubleshooting

**2026-11-22 最新の引き継ぎ / operational snapshot:** [日本語](HANDOFF-2026-11-22.ja.md) · [English](HANDOFF-2026-11-22.md). This file retains chronological findings; earlier statements marked *unverified* were superseded by later tests. Guest Agent bulk transfers are currently unreliable.

[Start (English)](README.md) | [日本語](README.ja.md)

## Read-only checks

~~~sh
sudo -n -H -u cpansmoke /usr/bin/find /home/cpansmoke/reports -type f -name '*.rpt' -print
sudo -n -H -u cpansmoke /usr/local/bin/perl ./docs/cpan-testers/scripts/check-reports.pl /home/cpansmoke/reports
sudo -n -H -u cpansmoke /bin/sh -c 'grep -E "^[[:space:]]*(transport|send_report)[[:space:]]*=" "$HOME/.cpanreporter/config.ini"'
~~~

## Service lifecycle (inside FreeBSD as root)

~~~sh
service cpansmoker onestart
service cpansmoker onestatus
tail -n 80 /home/cpansmoke/logs/cpansmoker.log
service cpansmoker onestop
~~~

Only after successful stop/start tests should you use **sysrc cpansmoker_enable=YES** for startup. **sysrc cpansmoker_enable=NO** disables boot startup. The bundled service is an adaptation of the working launch pattern, not a bit-for-bit verified VM export.

## What common messages mean

| Observation | Interpretation / action |
| --- | --- |
| **SHORTCUT exit 0** | Only argument/startup checks; **no real test** |
| **already tested** | Smoker found a matching history entry and skipped the distribution |
| **grade = pass** | Local test history records PASS; not proof of server receipt |
| **.rpt under hold/** | Local staging; does not mean already submitted |
| **No metabase_id.json on tester** | Expected for File transport; keep sender profile on sender |
| **qm guest exec exitcode 0** | Detached launcher may exit before its Perl child; inspect logs/PID |
| **Duplicate log blocks** | daemon -o **appends**, so tail may include older runs |
| **daemon -R 60** | Restarts the child 60s after termination; not a full scan every minute |
| **No .pid after exit** | daemon -P may remove its supervisor PID file on normal exit |

## Avoiding unwanted duplicate submissions

Never automatically send a local report just because it is named **pass.**. Parse and inspect it; distinguish already submitted content from new content; keep a durable submission ledger on the **sender**, never in a disposable tester snapshot. Restoring the tester snapshot can rewind its local history. Reconcile sender state before attempting to submit anything again.

## Preventing leaks

Do not commit real **.rpt**, logs, **metabase_id.json**, **.cpanreporter/config.ini**, passwords or identifiers from your actual VM. Reports can include environment information. Use samples and redaction for public bug reports.

References: [CPAN::Reporter::Smoker](https://metacpan.org/pod/CPAN::Reporter::Smoker), [FreeBSD rc scripting](https://docs.freebsd.org/en/articles/rc-scripting/), [FreeBSD daemon(8)](https://man.freebsd.org/cgi/man.cgi?query=daemon&sektion=8).

## Log rotation for continuous CPAN smoke testing

The original log reached **1.1 MB in about six minutes** during XS compilation. Configure FreeBSD's built-in newsyslog before leaving a long-running smoker unattended. **Do not use logrotate, truncate a live log, or manually rename an open logfile.**

The accompanying files are:

- [rc.d reference](scripts/cpansmoker) with daemon's **-H** option added (reopens the **-o** file on SIGHUP).
- [newsyslog configuration](newsyslog.conf.d/cpansmoker.conf), designed for one log file and the daemon supervisor's **-P** PID file.

The rotation entry retains 7 archived logs and rotates above 10 MiB at the next scheduled newsyslog run (default hourly). It keeps mode 0600 and cpansmoke ownership. The **PZ** flags keep the newest archive uncompressed, compress older archives with gzip and permit the daemon to switch to the new log before compression. This is log retention, **not report retention**; never delete .rpt files using log rules.

**Important sequencing for an existing running instance:**

1. Inspect the *actual* VM's /usr/local/etc/rc.d/cpansmoker, existing newsyslog entries and live daemon command.
2. Change the existing rc.d's daemon invocation from **-f -R 60** to **-f -H -R 60**, preserving every other argument. The current daemon process will **not** pick up this new flag until service restart.
3. During an approved maintenance window, run **service cpansmoker onestop**, confirm stopped, then **service cpansmoker onestart**. A smoke test in progress may be interrupted; this is intentionally not performed automatically by the guide.
4. Only **after** the supervisor is running with -H, install newsyslog.conf.d/cpansmoker.conf in /usr/local/etc/newsyslog.conf.d/ (verify the host's /etc/newsyslog.conf includes that directory, and check for duplicate stanzas). Preview **newsyslog -n -v -f /etc/newsyslog.conf**. Do not force rotation until the running PID/signal path has been verified.
5. Observe **service cpansmoker onestatus**, file ownership, log growth, and a subsequent rotation. SIGHUP must be sent to the supervisor PID file, not the Perl child.
6. Ensure cron's regular newsyslog job is enabled. If using nonstandard cron settings, check its frequency; **10M** is a threshold, not a hard upper bound.

**Safe inspection from Proxmox (no changes):**

~~~sh
qm guest exec 152 -- /bin/sh -c '
  echo "=== actual daemon rc.d ==="
  /usr/bin/grep -n -E "daemon|command|pidfile|procname" /usr/local/etc/rc.d/cpansmoker
  echo "=== newsyslog includes and existing entries ==="
  /usr/bin/grep -n -E "include|cpansmoker" /etc/newsyslog.conf
  /usr/bin/find /etc/newsyslog.conf.d /usr/local/etc/newsyslog.conf.d \
    -type f -name "*.conf" -exec /usr/bin/grep -Hn "cpansmoker" {} + 2>/dev/null || :
  echo "=== current process ==="
  /bin/ps -axo pid,ppid,etime,command | /usr/bin/grep -E "cpansmoker-run|daemon: /usr/local/libexec/cpansmoker-run" | /usr/bin/grep -v grep
  echo "=== cron and disk ==="
  /usr/sbin/service cron onestatus || :
  /bin/df -h /home/cpansmoke
'
~~~

For the existing test VM, avoid a reboot solely for rotation setup. Reboot recovery can be verified in a separate planned maintenance window after observing at least one completed normal rotation and ensuring tests can be safely interrupted.

## Verified pre-rotation state on the original VM (2026-11-22)

The actual VM 152 showed:

- Its rc.d line runs \`sudo -n -H -u cpansmoke /usr/sbin/daemon -f -R 60 ...\`: **sudo -H** is already present, but **daemon -H** is still absent.
- \`/etc/newsyslog.conf\` includes \`/usr/local/etc/newsyslog.conf.d/[!.]*.conf\`.
- No existing cpansmoker newsyslog rule was found.
- \`cron\` is running.

**Do not confuse the sudo and daemon flags.** The actual rc.d script must have the substring **/usr/sbin/daemon -f -H -R 60** before rotation can be enabled and the service must be restarted to apply it.

Minimal, reversible update on the FreeBSD VM (backup to .before-newsyslog), performed only when interruption of the active test is acceptable:

~~~sh
rc=/usr/local/etc/rc.d/cpansmoker
cp -p "$rc" "$rc.before-newsyslog"
sed 's@/usr/sbin/daemon -f -R 60@/usr/sbin/daemon -f -H -R 60@' "$rc.before-newsyslog" > "$rc.new"
sh -n "$rc.new" && grep -F "daemon -f -H -R 60" "$rc.new"
# Stop the live service before replacing the script, then start it once.
service cpansmoker onestop
install -o root -g wheel -m 0555 "$rc.new" "$rc"
rm -f "$rc.new"
service cpansmoker onestart
service cpansmoker onestatus
~~~

If replacement fails, restore **cpansmoker.before-newsyslog** and start the original service. Only after the restarted daemon is confirmed with **-H** should the accompanying newsyslog example be installed and previewed:

~~~sh
install -d -m 0755 /usr/local/etc/newsyslog.conf.d
install -o root -g wheel -m 0644 docs/cpan-testers/newsyslog.conf.d/cpansmoker.conf /usr/local/etc/newsyslog.conf.d/cpansmoker.conf
newsyslog -n -v -f /etc/newsyslog.conf /home/cpansmoke/logs/cpansmoker.log
~~~

The last command is a **dry run**, not a rotation. Run commands as FreeBSD root from the repository clone root, or use absolute paths to files. Avoid any forced rotation until you see a healthy live daemon supervisor, PID file and working output.

## Bounded stop / preventing a second smoker

The original service used rc.subr's default **stop**, which could wait for a long-running test. An **experimental, fail-closed** rc.d candidate and its upgrade/rollback steps are documented in [SAFE-STOP.md](SAFE-STOP.md) ([日本語](SAFE-STOP.ja.md)). It adds a 90-second bound and refuses a restart while any processes owned by the dedicated cpansmoke user remain. It does **not** automatically SIGKILL tests. **On VM 152, the 90-second timeout and a later single-instance recovery were verified; complete graceful standalone stop was not.** See the [latest handoff](HANDOFF-2026-11-22.md) before any maintenance.

## QEMU Guest Agent cross-VM copy proof (2026-11-22)

VM 152 and VM 151 reside on separate Proxmox bridges (`vmbr2` / `vmbr1`). The host has routes to both guests but TCP/22 probes from the host to both guests failed; direct VM 151 → VM 152 SSH was also unreachable. Do **not** relax isolation solely for report transfer.

An end-to-end test succeeded using Proxmox's `pvesh` QEMU Guest Agent file APIs: `/nodes/<node>/qemu/152/agent/file-read` read VM 152's harmless `/etc/shells`; the host transferred Base64-encoded content to `/nodes/<node>/qemu/151/agent/file-write` with `--encode 0`; a readback from VM 151 was byte-for-byte equal (Base64 values matched). Output: `SUCCESS: VM 152 -> Proxmox -> VM 151`, `Content verified`. The temporary test file was removed.

**Scope of proof:** small text-file delivery between guest temporary locations, **not** a tested production report mover. Before handling real `.rpt` files, check QGA file-read size/truncation, copy to a staging path, compare hashes/lengths, exclude VM 152 `reports/hold`, avoid duplicates against VM 151 `sent` by report identity (not filename only), and use `incoming` only after complete validation. A successful transfer must not trigger public submission automatically. Preserve the 19 existing `sent` reports, and do not retry `inflight` without manual disposition.

## One-report Metabase submission verified (2026-11-22)

A single real PASS report for `DBI-1.656` (FreeBSD 15.1-release-p6) was successfully transferred from VM 152 to VM 151 using Proxmox QEMU Guest Agent. A large direct `agent/file-write` of the 19,063-byte report had first timed out and left the guest agent unresponsive; the guest remained live, and `service qemu-guest-agent restart` restored responsiveness. A 1,024-byte readback test succeeded. Subsequently, the report was transferred in **19 chunks of 1,024 bytes** over `qm guest exec 151 --pass-stdin`, compared via **SHA-256**, and staged under a private `/tmp/cpan-stage.*` directory on VM 151.

The report was parsed with Test::Reporter as `DBI-1.656`, `pass`, subject `PASS DBI-1.656 amd64-freebsd-thread-multi 15.1-release-p6`; no matching report was found in VM 151's `incoming`, `inflight` or `sent` queues. It was then staged into `/home/cpansend/incoming` with user `cpansend`, mode `0600`, and a matching SHA-256. Before the send there were **1 incoming / 0 inflight / 19 sent** reports.

VM 151 has `/usr/bin/su` but **no `/usr/local/bin/sudo`**. The attempted preflight requiring sudo exited 1 **before submission**; there was no external send attempt in that step. The actual send invoked the **existing** sender using `qm guest exec 151 -- /usr/bin/su -m cpansend -c 'HOME=/home/cpansend /usr/local/bin/perl /home/cpansend/send-batch.pl'` with preflight checks. The script returned **exit code 0**, printed `Sending: PASS DBI-1.656 ...` and `SENT: pass.DBI-1.656....rpt`.

**Verified:** one end-to-end report transfer and successful sender return. **Not yet verified:** post-send queue counts, public CPAN Testers ingestion/display, unattended periodic transfer, auto-submission, failure recovery, and policy for FAIL/UNKNOWN grades. Do not interpret `SENT` as proof of public visibility or automatically resend uncertain `inflight` records.

## Post-send DBI queue verification (2026-11-22)

Following the successful `DBI-1.656` Metabase send via the existing `send-batch.pl`, a **read-only queue count** on VM 151 confirmed:

- `incoming/*.rpt`: **0**
- `inflight/*.rpt`: **0**
- `sent/*.rpt`: **20** (previously 19)

Thus the submitted DBI report left `incoming`, did not remain in `inflight`, and was filed under `sent`. The sender returned exit code 0 and printed `SENT`. This verifies **one complete transfer-and-send workflow**, not unattended scheduling or public CPAN Testers visibility.

**Operational next step:** automate only the *staging/transfer* phase first with bounded 1,024-byte guest-exec stdin chunks, SHA-256 validation, and report-level deduplication; enable unattended submission only after failure handling is tested. Preserve existing `sent` reports and the `hold` subtree.
