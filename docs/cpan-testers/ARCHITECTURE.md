# Architecture: isolated testing and separate submission

[Start (English)](README.md) | [日本語](README.ja.md)

The original setup used **Proxmox VE 8.4** and two FreeBSD 15.1 VMs. IDs are examples.

~~~text
             Proxmox VE host
        (QEMU Guest Agent control)
                    |
       +------------+-------------+
       |                          |
 VM 152: TESTER                VM 151: SENDER
 cpansmoke (non-root)          Metabase identity (private)
 CPAN::Reporter::Smoker        controlled submit queue
       |                          ^
 File transport: .rpt              |
       +-- review + SHA-256 -------+
                    |
              CPAN Testers
~~~

## Security boundary

**VM 152:** executes untrusted CPAN build/test code; use no Metabase profile, no credentials or host-mounted secrets. Local files are stored in **/home/cpansmoke/reports/**. **hold/** is a staging convention, not an intrinsic File transport directory.

**VM 151:** is the only machine with an authorized sender profile and permission to submit. Review report contents and prevent duplicate posts. The Proxmox host may coordinate transfers via QEMU Guest Agent but must not treat reports as executable code.

**SHA-256 checks integrity of copied bytes only.** It does not prove a compromised tester produced truthful reports. For safe unattended sending, a future implementation must isolate incoming files, validate size/path, verify hashes, parse via Test::Reporter, review/privacy-check, atomically queue, record successful submissions durably and handle ambiguous network results without automatic duplicates.

## What is reproducible today

The public guide reproduces **local testing, File transport, report parsing, and a reference rc.d-based service**. The original environment produced PASS reports for **File-Marker-0.14**, **Algorithm-Diff-1.201**, **Text-Diff-1.46**, on **amd64-freebsd-thread-multi / FreeBSD 15.1-RELEASE-p6 / Perl 5.42.3**. The original sender was used separately, but **its validated transfer and send-batch implementation is not included here** because a portable, credential-safe and idempotent version has not yet been reviewed.

Do not interpret the existence of local .rpt files as proof of public submission. Do not paste a personal profile or real test reports into a public issue. See [OPERATIONS.md](OPERATIONS.md).
