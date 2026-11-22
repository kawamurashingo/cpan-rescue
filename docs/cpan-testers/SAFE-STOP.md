# Bounded and fail-closed rc.d stop for a CPAN Smoker

[日本語](SAFE-STOP.ja.md) · [Full guide](README.md)

**Status: candidate, static shell syntax checked; not yet validated on the live VM.** The proven production VM 152 currently runs the original rc.d script. Do not overwrite it while assuming this candidate is already proven.

The original FreeBSD `rc.subr` stop invokes `wait_for_pids` after SIGTERM and may wait indefinitely when a supervised Perl/CPAN test tree is still active. Its default restart also runs start after stop without checking the first return code. The candidate [cpansmoker-guarded](scripts/cpansmoker-guarded) changes those behaviors. Source: [FreeBSD rc.subr](https://cgit.freebsd.org/src/tree/libexec/rc/rc.subr).

## Policy

- Send SIGTERM **only to the verified supervisor PID** from daemon's `-P` pidfile.
- Wait a configurable **90 seconds maximum**, then **return error**. Never escalate automatically to SIGKILL.
- If the supervisor exits but processes owned by the **dedicated cpansmoke user** still remain, **return error**.
- Refuse start while any processes of cpansmoke remain, preventing concurrent smoke tests and orphan overlap.
- The overridden restart **stops on error** rather than launching a second supervisor.
- Keep the existing File transport, newsyslog and `daemon -H -R 60` settings unchanged.

**Trade-off:** stopping a currently running dependency test may interrupt it. Failure to stop in 90 seconds is not a success: an administrator must inspect the process tree, and the VM reboot should not proceed as a routine maintenance action. The "all processes owned by cpansmoke" guard assumes this is a **dedicated account**; unrelated interactive user sessions will intentionally block a restart.

## Safe upgrade plan

From Proxmox, while the current Smoker is still operating, verify the existing service and do a **read-only preflight**:

~~~sh
qm guest exec 152 -- /usr/sbin/service cpansmoker onestatus
qm guest exec 152 -- /bin/sh -c 'grep -E "^(command_args|pidfile|procname)=" /usr/local/etc/rc.d/cpansmoker; /usr/sbin/sysrc cpansmoker_enable'
~~~

At a maintenance window, **review and back up** the installed rc.d before replacing it with the candidate; a script file can be replaced while its previously started daemon keeps running, but the next invocation of `service` will use the new script. Use an immutable Git commit URL and verify the downloaded file checksum/content prior to installation; **never fetch a moving main-branch file blindly as root.**

~~~sh
# Inside FreeBSD VM as root, with candidate file already copied and reviewed:
rc=/usr/local/etc/rc.d/cpansmoker
cp -p "$rc" "$rc.before-guarded-stop"
sh -n /tmp/cpansmoker-guarded
install -o root -g wheel -m 0555 /tmp/cpansmoker-guarded "$rc"
service cpansmoker onestatus
# Only when interruption is acceptable:
service cpansmoker onestop
~~~

If stop returns nonzero, do not run `onestart`, `onerestart` or reboot. Inspect **/bin/ps -axo pid,ppid,user,stat,etime,command** and service status. If stop succeeds, `service cpansmoker onestart` should start exactly one supervisor, and `onestatus` should report its PID. Ensure there are no orphaned CPAN tasks. Then use a separate controlled VM reboot to validate automatic service start. The reboot test is **not** included here because it interrupts the active CPAN job.

Rollback (after ensuring no simultaneous stop/start is in progress):

~~~sh
cp -p /usr/local/etc/rc.d/cpansmoker.before-guarded-stop /usr/local/etc/rc.d/cpansmoker
sh -n /usr/local/etc/rc.d/cpansmoker
~~~

**Caution:** blindly restoring the old script while running is possible, but it also restores its potentially unbounded stop behavior. Inspect the active processes and prefer to fix the candidate if an error is discovered.
