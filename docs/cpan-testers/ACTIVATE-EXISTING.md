# Activate automatic CPAN smoke testing on the existing FreeBSD VM 152

[Full guide](README.md) | [日本語](ACTIVATE-EXISTING.ja.md)

**Scope:** The reference FreeBSD 15.1 VM already has a working cpansmoke user, CPAN::Reporter::Smoker, File transport, rc.d service, and daemon supervision. Only two things remain: replace the fixed one-distribution runner with an all-CPAN runner, and enable boot startup. **Do not install more packages, alter reports, or configure public submissions.**

Run these commands from the **Proxmox host** with QEMU Guest Agent enabled.

## Replace runner; verify service

The command retrieves a runner from a **pinned GitHub commit**, checks its shell syntax and expected content, backs up the existing runner once to **.preauto**, stops the service before replacing its executable, then starts the updated service.

~~~sh
qm guest exec 152 -- /bin/sh -c '
  set -eu
  runner=/usr/local/libexec/cpansmoker-run
  tmp=$(/usr/bin/mktemp /tmp/cpansmoker-run.XXXXXX)
  /usr/bin/fetch -q -o "$tmp" \
    https://raw.githubusercontent.com/kawamurashingo/cpan-rescue/a1d9d6386085349601c9b7f11afc18d8f37b94b9/docs/cpan-testers/scripts/cpansmoker-run
  /bin/sh -n "$tmp"
  /usr/bin/grep -Fq "unset PERL_CR_SMOKER_SHORTCUT" "$tmp"
  /usr/bin/grep -Fq "unset PERL_CR_SMOKER_RUNONCE" "$tmp"
  /usr/bin/grep -Fq "start(install => 0, set_term_title => 0)" "$tmp"
  test -f "$runner"
  test -f /usr/local/etc/rc.d/cpansmoker
  if /usr/sbin/service cpansmoker onestatus >/dev/null 2>&1; then
    /usr/sbin/service cpansmoker onestop
  fi
  if /usr/sbin/service cpansmoker onestatus >/dev/null 2>&1; then
    echo "ERROR: service still running; not replacing runner"
    exit 1
  fi
  if [ ! -e "$runner.preauto" ]; then /bin/cp -p "$runner" "$runner.preauto"; fi
  /usr/bin/install -o root -g wheel -m 0555 "$tmp" "$runner"
  /bin/rm -f "$tmp"
  /usr/sbin/service cpansmoker onestart
  /usr/sbin/service cpansmoker onestatus
'
~~~

**Warning:** This starts real unattended CPAN tests with an unrestricted distribution list. Only use inside an isolated disposable VM with adequate disk capacity. File transport remains local.

~~~sh
qm guest exec 152 -- /usr/bin/tail -n 80 /home/cpansmoke/logs/cpansmoker.log
qm guest exec 152 -- /usr/bin/find /home/cpansmoke/reports -type f -name '*.rpt' -print
~~~

Verify both the service's supervisor status and evidence of work beyond the previously fixed one-distribution list.

## Enable boot startup only after observing a healthy run

~~~sh
qm guest exec 152 -- /usr/sbin/sysrc cpansmoker_enable=YES
qm guest exec 152 -- /usr/sbin/service cpansmoker onestatus
qm guest exec 152 -- /usr/sbin/sysrc cpansmoker_enable
~~~

## Stop and roll back

~~~sh
qm guest exec 152 -- /usr/sbin/service cpansmoker onestop
qm guest exec 152 -- /usr/sbin/sysrc cpansmoker_enable=NO
qm guest exec 152 -- /bin/sh -c '
  set -eu
  r=/usr/local/libexec/cpansmoker-run
  test -f "$r.preauto"
  /bin/cp -p "$r.preauto" "$r"
  /bin/sh -n "$r"
'
~~~

**This only automates test execution on VM 152**, not the VM 151 transfer/submission pipeline. An exitcode of 0 from **qm guest exec** does not prove a detached test later passed.

## Observed activation status (2026-11-22)

The actual FreeBSD test VM 152 has now:

- Fetched the CPAN indexes and entered `Smoker: scanning and sorting index` without the former fixed distribution list.
- Returned `cpansmoker is running as pid 3664.` from `service cpansmoker onestatus` (PID at observation time).
- Successfully set and read back `cpansmoker_enable: YES` using `sysrc`.

**Not yet verified:** automatic recovery after a VM reboot, completion of a *new* distribution test and report, or extended unattended reliability. File transport remains local; VM 151 sending is outside this activation step.

Non-disruptive verification from the Proxmox host:

~~~sh
qm guest exec 152 -- /usr/sbin/service cpansmoker onestatus
qm guest exec 152 -- /usr/bin/tail -n 100 /home/cpansmoke/logs/cpansmoker.log
qm guest exec 152 -- /usr/bin/find /home/cpansmoke/reports -type f -name '*.rpt' -print
~~~

### Real smoke-test progress (2026-11-22, from 09:12 JST)

The live VM log now shows `Smoker: found 44947 distributions on CPAN` and `Smoker: testing Mogura-0.01 [1/44947]`. The unrestricted smoker is selecting and running a distribution automatically. Several `Result: PASS` lines were observed, but they do **not** independently prove a completed final report was written.

At this observation, the service reported PID 3664 and disk usage was 6% with 49 GB available. **Still unverified:** a final Mogura-0.01 .rpt, startup after a VM reboot, long-running reliability, and VM-to-VM transfer. Finding 44,947 candidate distributions does not mean 44,947 tests have completed.

~~~sh
qm guest exec 152 -- /usr/bin/find /home/cpansmoke/reports -type f -name '*.rpt' -print
~~~

### Automatic report generation confirmed (2026-11-22)

The unrestricted smoker on VM 152 selected `Mogura-0.01 [1/44947]`, followed by `SNMP-Info-3.985003 [2/44947]`. Newly written **local File transport reports** appeared in `/home/cpansmoke/reports/`.

In the last 20 files listed, **19 PASS** reports and **one FAIL** report were shown, including:

- `fail.Mogura-0.01.*.rpt`
- `pass.DBD-SQLite-1.78.*.rpt`
- `pass.Mojolicious-9.54.*.rpt`
- `pass.Module-Build-0.4234.*.rpt`

Dependency distributions were tested as well. **A FAIL report is not itself a smoker-service failure**; inspect the report body to diagnose the actual test failure. The 19/1 split is based only on the displayed last 20 files, **not** a full running total.

**Verified:** automatic CPAN target selection, build/test activity, local PASS and FAIL report generation, running service, and `cpansmoker_enable=YES` configuration.

**Not yet verified:** VM-reboot auto-recovery, long-term stability, or submission to public CPAN Testers through VM 151. The test VM retains File transport.

### Report count (2026-11-22, observed snapshot)

A recursive count of `/home/cpansmoke/reports` on VM 152 found **33 PASS / 1 FAIL / 2 UNKNOWN / 0 NA = 36 local report files**. The service was running as PID 3664. Root filesystem: **3.3 GB used of 57 GB (6%), 49 GB free**.

This counts **local report files**, not completed tests across all CPAN or submissions received by CPAN Testers. Individual FAIL/UNKNOWN causes must be investigated from report contents. Automatic CPAN selection and local report generation are observed; **reboot recovery, extended stability, and VM 151 submission automation remain unverified**.

### Next operational improvement: safe log rotation

XS builds can increase the log quickly. The [reference rc.d template](scripts/cpansmoker) now includes **daemon -H**, and a [newsyslog config example](newsyslog.conf.d/cpansmoker.conf) rotates above **10 MiB**, retaining **7 archives**. Archive retention does not apply to reports.

**Do not activate newsyslog rotation on the existing VM before verifying and updating its *actual* rc.d launch command and doing a controlled restart**: a running supervisor without **-H** will not reopen the log when SIGHUP is sent. See [OPERATIONS.md](OPERATIONS.md#log-rotation-for-continuous-cpan-smoke-testing) for the non-invasive inspection and activation sequence. A VM reboot test follows during an approved maintenance window.

### Live log rotation verified (2026-11-22)

On FreeBSD VM 152 the installed rc.d was updated to launch `/usr/sbin/daemon -f -H -R 60`, then Smoker was restarted. The supervisor ran as PID **23755**, with Smoker child PID **23756**, and resumed CPAN index scanning.

The newsyslog configuration in `/usr/local/etc/newsyslog.conf.d/cpansmoker.conf` passed dry-run validation. A forced, single-log `newsyslog -F -P -v` run showed:

- An approximately **5.8 MB** archived `cpansmoker.log.0`;
- A new `cpansmoker.log` with **8.6 KB** at observation time;
- SIGHUP notification to supervisor PID **23755**;
- `service cpansmoker onestatus` still reporting **PID 23755** afterward.

This verifies a **non-disruptive manual rotation** with the service remaining active. Continued output growth, a subsequent automatically scheduled rotation, and recovery after a FreeBSD VM reboot are separate checks. Local File transport does not constitute public CPAN Testers submission.

### Continued writing after log rotation verified (2026-11-22)

The new `cpansmoker.log` grew from approximately **8.6 KB** immediately after rotation to **276 KB** at follow-up. `service cpansmoker onestatus` continued to report supervisor PID **23755** and `sysrc cpansmoker_enable` returned **YES**. New log output included **20 files / 75 tests, All tests successful, Result: PASS**.

This confirms the active Smoker **continued writing into the new log and running tests after live rotation**.

**Remaining:** recovery after an actual VM reboot, multi-day operation, and submitting via VM 151. A prior rc.d stop request waited for a prolonged time during active dependency tests; plan a maintenance window and inspect active tests before rebooting.
