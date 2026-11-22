# FreeBSD smoker operations / troubleshooting

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
