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
