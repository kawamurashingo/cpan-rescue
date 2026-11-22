# Become a CPAN Tester on FreeBSD / Proxmox

**[日本語ガイド](README.ja.md)** | [Architecture](ARCHITECTURE.md) | [Operations](OPERATIONS.md)

A reproducible path from a dedicated **FreeBSD 15.1 / Perl 5.42** virtual machine to local CPAN test reports and, optionally, public CPAN Testers submissions. Based on a working Proxmox-hosted reference environment. **Proxmox is optional.**

**WARNING:** CPAN smoke tests execute code uploaded by strangers. Use a disposable, isolated VM; never a production host. Keep snapshots, restrict resources, remove credentials and host shares. Test reports may reveal environment details.

## 1. Install on FreeBSD (as root)

~~~sh
pkg update
pkg install sudo perl5 p5-CPAN-Reporter p5-CPAN-Reporter-Smoker p5-Test-Reporter
pw useradd cpansmoke -m -s /bin/sh
install -d -o cpansmoke -g cpansmoke -m 0700 /home/cpansmoke/logs
install -d -o cpansmoke -g cpansmoke -m 0700 /home/cpansmoke/reports
install -d -o cpansmoke -g cpansmoke -m 0700 /home/cpansmoke/reports/hold
sudo -n -H -u cpansmoke /usr/local/bin/perl -MCPAN::Reporter::Smoker -MTest::Reporter -e 'print "modules OK\n"'
~~~

Skip useradd if the account exists. Version availability varies by FreeBSD release.

## 2. Configure CPAN and local File transport

~~~sh
sudo -H -u cpansmoke /usr/local/bin/perl -MCPAN -e shell
~~~

In the CPAN shell, complete mirror initialization and enter:

~~~text
o conf init test_report
o conf commit
quit
~~~

In **/home/cpansmoke/.cpanreporter/config.ini**, preserve other wizard settings and configure your *own* email address plus:

~~~ini
email_from = your-email@example.org
transport = File /home/cpansmoke/reports
send_report = yes
send_duplicates = no
command_timeout = 1200
~~~

**send_report = yes** with **File** means creating local files, not publishing on CPAN Testers. Keep CPAN's **test_report** enabled. Do not configure public Metabase sending yet.

## 3. Run one actual test

~~~sh
sudo -n -H -u cpansmoke /usr/bin/env \
  PERL_CR_SMOKER_RUNONCE=1 \
  /usr/local/bin/perl -MCPAN::Reporter::Smoker \
  -e 'start(list => [q{NEILB/Text-Diff-1.46.tar.gz}], install => 0, set_term_title => 0)'
~~~

**SHORTCUT=1** would bypass testing: do not set it. **already tested** means cached test history caused a skip, not a new PASS. Inspect reports:

~~~sh
sudo -n -H -u cpansmoke /usr/bin/find /home/cpansmoke/reports -type f -name '*.rpt' -print
sudo -n -H -u cpansmoke /usr/local/bin/perl ./docs/cpan-testers/scripts/check-reports.pl /home/cpansmoke/reports
~~~

Run the read-only check script from this repository's root (or use its absolute path). The original environment successfully read PASS reports for **File-Marker-0.14**, **Algorithm-Diff-1.201** and **Text-Diff-1.46**.

## 4. Optional unattended FreeBSD service

Only after safely reviewing a real report, run from a clone of this repository as root **inside FreeBSD**:

~~~sh
install -m 0555 docs/cpan-testers/scripts/cpansmoker-run /usr/local/libexec/cpansmoker-run
install -m 0555 docs/cpan-testers/scripts/cpansmoker /usr/local/etc/rc.d/cpansmoker
sh -n /usr/local/etc/rc.d/cpansmoker
sh -n /usr/local/libexec/cpansmoker-run
service cpansmoker onestart
service cpansmoker onestatus
tail -n 80 /home/cpansmoke/logs/cpansmoker.log
service cpansmoker onestop
~~~

These scripts are **reference templates based on the observed setup, not an exact copy of installed files**. Verify lifecycle on your VM before boot-enabling:

~~~sh
sysrc cpansmoker_enable=YES
service cpansmoker start
~~~

The runner removes the one-distribution restriction to scan CPAN continuously. **daemon -R 60** restarts a terminated child after 60 seconds; it is *not* a 60-second polling interval.

## 5. Submit to CPAN Testers (a separate, optional step)

Local .rpt files are **not** public submissions. Read the official [CPAN::Reporter](https://metacpan.org/pod/CPAN::Reporter) / [Smoker](https://metacpan.org/pod/CPAN::Reporter::Smoker) docs. A single-VM operator can install **p5-Test-Reporter-Transport-Metabase** and **p5-Metabase-Fact**, create their own identity with **metabase-profile**, protect **~/.cpanreporter/metabase_id.json** as 0600, and configure **transport = Metabase** when ready.

For stronger separation, follow the reference **VM 152 (untrusted tests) → local File reports → SHA-256 verified transfer → VM 151 (credentialed sender)** model in [ARCHITECTURE.md](ARCHITECTURE.md). Keep sender credentials off the tester, review content, and ensure durable duplicate prevention. Do not automatically re-send existing reports.

## Optional Proxmox guest-agent checks

Replace 152 with your own FreeBSD test VM ID:

~~~sh
qm guest exec 152 -- /usr/local/bin/sudo -n -H -u cpansmoke \
  /usr/local/bin/perl -MCPAN::Reporter::Smoker -e 'print "Perl OK\n"'
qm guest exec 152 -- /usr/bin/tail -n 80 /home/cpansmoke/logs/cpansmoker.log
~~~

An exitcode of 0 for a detached daemon launcher does **not** establish the outcome of the later smoke test.

## Validation status

**Observed:** working cpansmoke/Smoker/File transport on FreeBSD 15.1; three readable PASS reports; tested rc.d lifecycle and daemon restart behavior on the original machine.

**Not yet independently verified:** a clean-room reproduction of this public guide; the generalized bundled rc.d script; complete cross-VM transfer/queue automation; multi-day unattended operation. These are future validation tasks, not claimed successes.

See [OPERATIONS.md](OPERATIONS.md) for troubleshooting. Sources: [CPAN::Reporter](https://metacpan.org/pod/CPAN::Reporter), [Smoker](https://metacpan.org/pod/CPAN::Reporter::Smoker), [FreeBSD rc.d](https://docs.freebsd.org/en/articles/rc-scripting/).
