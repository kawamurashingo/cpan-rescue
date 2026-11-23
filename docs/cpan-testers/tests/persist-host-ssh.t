use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use FindBin;
use IPC::Open3;
use Symbol qw(gensym);
use Fcntl qw(LOCK_EX LOCK_NB);

my $script = "$FindBin::Bin/../scripts/persist-host-ssh.sh";
my $dir = tempdir(CLEANUP => 1);
my $bin = "$dir/bin";
make_path($bin);

sub write_file {
    my ($path, $text) = @_;
    open my $fh, '>', $path or die "$!: $path";
    print {$fh} $text or die $!;
    close $fh or die $!;
}
sub read_file {
    open my $fh, '<', $_[0] or die "$!: $_[0]";
    local $/;
    return <$fh>;
}

write_file("$bin/nft", <<'MOCK');
#!/usr/bin/perl
use strict;
use warnings;
die "unexpected nft invocation" unless @ARGV == 3 && $ARGV[0] eq '--check' && $ARGV[1] eq '--file';
open my $fh, '>>', $ENV{CPAN_TEST_NFT_LOG} or die $!;
print {$fh} join(' ', @ARGV), "\n";
if ($ENV{CPAN_TEST_EDIT_CURRENT} && $ARGV[2] =~ /cpan152\.next/) {
    open my $changed, '>>', $ENV{CPAN_TEST_EDIT_CURRENT} or die $!;
    print {$changed} "# concurrent edit\n";
    close $changed or die $!;
}
exit 1 if $ENV{CPAN_TEST_NFT_FAIL} && $ARGV[2] =~ /cpan152\.next/;
exit 0;
MOCK
chmod 0755, "$bin/nft" or die $!;
local $ENV{PATH} = "$bin:$ENV{PATH}";
local $ENV{CPAN_TEST_NFT_LOG} = "$dir/nft.log";

sub fixture {
    my ($name) = @_;
    my $root = "$dir/$name";
    my $baseline = "$root/baseline";
    my $config = "$root/config with spaces";
    make_path($baseline, $config);
    for my $id (151, 152) {
        my $bridge = $id == 151 ? 'vmbr1' : 'vmbr2';
        my $source = <<"NFT";
table inet cpan${id}_filter {
    chain input {
        type filter hook input priority -50; policy accept;
        iifname "$bridge" drop
    }
    chain forward {
        type filter hook forward priority -50; policy accept;
        iifname "$bridge" ip daddr { 10.0.0.0/8, 192.168.0.0/16 } drop
        iifname "$bridge" drop
    }
}
NFT
        write_file("$baseline/cpan$id.nft", $source);
        write_file("$config/cpan$id.nft", $source);
    }
    return ($baseline, $config);
}

sub run_persist {
    my ($baseline, $config, @options) = @_;
    my $err = gensym;
    my $pid = open3(my $in, my $out, $err, 'sh', $script,
        '--baseline-dir', $baseline, '--config-dir', $config, @options);
    close $in;
    local $/;
    my $stdout = <$out> // '';
    my $stderr = <$err> // '';
    waitpid($pid, 0);
    return ($? >> 8, $stdout, $stderr);
}

my ($baseline, $config) = fixture('normal');
my ($rc, $out, $err) = run_persist($baseline, $config);
is($rc, 0, 'plan succeeds');
like($out, qr/PLAN_ONLY/, 'plan is identified');
for my $id (151, 152) {
    is(read_file("$config/cpan$id.nft"), read_file("$baseline/cpan$id.nft"), "plan preserves VM $id original");
}
($rc, $out, $err) = run_persist($baseline, $config, '--apply');
is($rc, 0, 'apply succeeds') or diag $err;
like($out, qr/PERSISTENCE_FILES_VERIFIED/, 'completion reported after verification');
my ($backup) = $out =~ /^Backups and candidates: (.+)$/m;
ok(defined($backup) && -d $backup, 'backup directory retained');
for my $id (151, 152) {
    my $changed = read_file("$config/cpan$id.nft");
    like($changed, qr/cpan-rescue-host-ssh-$id/, "VM $id persistence rule present");
    is(read_file("$backup/cpan$id.before.nft"), read_file("$baseline/cpan$id.nft"), "VM $id original backup preserved");
    my $removed = $changed =~ s/^[ \t]*[^\n]*comment "cpan-rescue-host-ssh-$id"\n//m;
    is($removed, 1, "VM $id has exactly one added rule");
    is($changed, read_file("$baseline/cpan$id.nft"), "VM $id other bytes preserved");
    is((stat("$config/cpan$id.nft"))[2] & 0777, 0600, "VM $id configuration private");
}
my @first = map { read_file("$config/cpan$_.nft") } (151, 152);
($rc, $out, $err) = run_persist($baseline, $config, '--apply');
is($rc, 0, 'repeat apply succeeds');
like($out, qr/VM 151: already current/, 'repeat detects existing VM 151 update');
like($out, qr/VM 152: already current/, 'repeat detects existing VM 152 update');
is(read_file("$config/cpan151.nft"), $first[0], 'repeat preserves VM 151 bytes');
is(read_file("$config/cpan152.nft"), $first[1], 'repeat preserves VM 152 bytes');

($baseline, $config) = fixture('mixed');
write_file("$config/cpan151.nft", $first[0]);
($rc, $out, $err) = run_persist($baseline, $config, '--apply');
is($rc, 0, 'partially installed state can be completed');
like($out, qr/VM 151: already current/, 'already installed first file is retained');
like($out, qr/VM 152: installed/, 'remaining second file is installed');
is(read_file("$config/cpan152.nft"), $first[1], 'remaining file matches exact candidate');

($baseline, $config) = fixture('unexpected');
write_file("$config/cpan152.nft", read_file("$config/cpan152.nft") . "# another edit\n");
my $unexpected = read_file("$config/cpan152.nft");
($rc, $out, $err) = run_persist($baseline, $config, '--apply');
isnt($rc, 0, 'unrelated current-file edit is refused');
is(read_file("$config/cpan151.nft"), read_file("$baseline/cpan151.nft"), 'VM 151 unchanged when VM 152 validation fails');
is(read_file("$config/cpan152.nft"), $unexpected, 'unrelated edit retained');

($baseline, $config) = fixture('nft-failure');
{
    local $ENV{CPAN_TEST_NFT_FAIL} = 1;
    ($rc, $out, $err) = run_persist($baseline, $config, '--apply');
}
isnt($rc, 0, 'second syntax-check failure is refused');
for my $id (151, 152) {
    is(read_file("$config/cpan$id.nft"), read_file("$baseline/cpan$id.nft"), "VM $id unchanged after syntax failure");
}

($baseline, $config) = fixture('symlink');
unlink "$config/cpan152.nft" or die $!;
symlink "$baseline/cpan152.nft", "$config/cpan152.nft" or die $!;
($rc, $out, $err) = run_persist($baseline, $config, '--apply');
isnt($rc, 0, 'symlink current file is refused');
is(read_file("$config/cpan151.nft"), read_file("$baseline/cpan151.nft"), 'first file untouched on second-file symlink');
ok(-l "$config/cpan152.nft", 'symlink target not replaced');

($baseline, $config) = fixture('concurrent-edit');
{
    local $ENV{CPAN_TEST_EDIT_CURRENT} = "$config/cpan151.nft";
    ($rc, $out, $err) = run_persist($baseline, $config, '--apply');
}
isnt($rc, 0, 'file changed during validation is refused');
is(read_file("$config/cpan151.nft"), read_file("$baseline/cpan151.nft") . "# concurrent edit\n", 'concurrent edit retained');
is(read_file("$config/cpan152.nft"), read_file("$baseline/cpan152.nft"), 'other file unchanged after concurrent edit');

($baseline, $config) = fixture('locked');
{
    open my $lock, '>>', "$config/cpan-host-ssh-persist.lock" or die $!;
    flock($lock, LOCK_EX | LOCK_NB) or die $!;
    ($rc, $out, $err) = run_persist($baseline, $config, '--apply');
    isnt($rc, 0, 'parallel installer is refused');
    like($err, qr/another persistence operation is running/, 'lock refusal is explicit');
    is(read_file("$config/cpan151.nft"), read_file("$baseline/cpan151.nft"), 'lock refusal leaves original unchanged');
}

my @calls = split /\n/, read_file("$dir/nft.log");
ok(@calls > 0, 'nft checks exercised');
is(scalar(grep { !/^--check --file / } @calls), 0, 'all nft calls are check-only');
done_testing;
