#!/usr/bin/perl
use strict;
use warnings;
use Fcntl qw(O_CREAT O_EXCL O_WRONLY);
use Getopt::Long qw(GetOptions);

# Prepare a candidate only; never load nftables or replace a live configuration.
my ($vm_id, $input, $output);
GetOptions('vm-id=i' => \$vm_id, 'input=s' => \$input, 'output=s' => \$output)
    or die "Invalid options\n";
die "Usage: $0 --vm-id 151|152 --input FILE --output NEW_FILE\n"
    if @ARGV || !defined($vm_id) || !defined($input) || !defined($output);
die "Only the documented VM 151/152 layout is supported\n"
    unless $vm_id == 151 || $vm_id == 152;
die "Input must be a regular file, not a symlink\n" if -l $input || !-f $input;

open my $in, '<', $input or die "Cannot read $input: $!\n";
my $source = do { local $/; <$in> };
close $in or die "Cannot close $input: $!\n";

my $bridge = $vm_id == 151 ? 'vmbr1' : 'vmbr2';
my $comment = "cpan-rescue-host-ssh-$vm_id";
my $rule = qq{iifname "$bridge" ip saddr 10.$vm_id.0.2 ip daddr 10.$vm_id.0.1 tcp sport 22 ct state established ct direction reply counter accept comment "$comment"};

# Fail closed on other layouts. The known input chain has no nested objects;
# forward/NAT chains, comments and all unrelated bytes are kept verbatim.
my $pattern = qr{
    (^[ \t]*table[ \t]+inet[ \t]+cpan${vm_id}_filter[ \t]*\{[ \t]*\n
     [ \t]*chain[ \t]+input[ \t]*\{[ \t]*\n)
    ([^{}]*?)
    (^[ \t]*\})
}mx;
my @chains = $source =~ /$pattern/g;
die "Expected exactly one documented input chain\n" unless @chains == 3;
my $body = $chains[1];
my @statements = grep { /\S/ && !/^\s*#/ } split /\n/, $body;
s/^\s+|\s+$//g for @statements;
my $hook = 'type filter hook input priority -50; policy accept;';
my $drop = qq{iifname "$bridge" drop};

if (@statements == 3 && $statements[0] eq $hook &&
        $statements[1] eq $rule && $statements[2] eq $drop) {
    die "Already configured; no candidate written\n";
}
die "Input chain differs from the documented default-drop layout; review manually\n"
    unless @statements == 2 && $statements[0] eq $hook && $statements[1] eq $drop;
die "SSH rule marker already exists elsewhere; review manually\n"
    if index($source, $comment) >= 0;

$body =~ s{^([ \t]*)(\Q$drop\E)[ \t]*$}{$1$rule\n$1$2}m
    or die "Cannot locate the input drop rule\n";
$source =~ s{$pattern}{$1$body$3};

# Exclusive creation also refuses existing files and symlink destinations.
sysopen my $out, $output, O_WRONLY | O_CREAT | O_EXCL, 0600
    or die "Cannot create new candidate $output: $!\n";
my $ok = eval {
    print {$out} $source or die "Cannot write $output: $!\n";
    close $out or die "Cannot close $output: $!\n";
    1;
};
if (!$ok) {
    my $error = $@;
    close $out;
    unlink $output or warn "Cannot remove incomplete candidate $output: $!\n";
    die $error;
}
print "Prepared $output; original unchanged. Review the diff before installation.\n";
