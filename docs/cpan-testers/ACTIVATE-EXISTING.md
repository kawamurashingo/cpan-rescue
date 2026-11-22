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
  /usr/bin/test -f "$runner"
  /usr/bin/test -f /usr/local/etc/rc.d/cpansmoker
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
  /usr/bin/test -f "$r.preauto"
  /bin/cp -p "$r.preauto" "$r"
  /bin/sh -n "$r"
'
~~~

**This only automates test execution on VM 152**, not the VM 151 transfer/submission pipeline. An exitcode of 0 from **qm guest exec** does not prove a detached test later passed.
