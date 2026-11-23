use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use FindBin;

my $script = "$FindBin::Bin/../scripts/prepare-host-ssh.pl";
my $dir = tempdir(CLEANUP => 1);

sub read_file {
    open my $fh, '<', $_[0] or die "$!: $_[0]";
    local $/;
    return <$fh>;
}

sub write_file {
    my ($path, $text) = @_;
    open my $fh, '>', $path or die "$!: $path";
    print {$fh} $text or die $!;
    close $fh or die $!;
}

sub prepare {
    my ($id, $in, $out) = @_;
    # Use argument lists, including in cases with shell metacharacters in paths.
    open my $fh, '-|', $^X, $script,
        '--vm-id', $id, '--input', $in, '--output', $out or die $!;
    local $/;
    my $message = <$fh>;
    close $fh;
    return ($? >> 8, $message);
}

for my $id (151, 152) {
    my $bridge = $id == 151 ? 'vmbr1' : 'vmbr2';
    my $in = "$dir/config $id; literal.nft";
    my $out = "$in.next";
    my $source = <<"NFT";
table inet cpan${id}_filter {
    chain input {
        type filter hook input priority -50; policy accept;
        # Retain this comment.
        iifname "$bridge" drop
    }
    chain forward {
        type filter hook forward priority -50; policy accept;
        iifname "$bridge" ip daddr { 10.0.0.0/8, 192.168.0.0/16 } drop
        iifname "$bridge" drop
        oifname "$bridge" ct state established,related accept
        oifname "$bridge" drop
    }
}
table ip cpan${id}_nat {
    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 10.$id.0.2 oifname "vmbr0" masquerade
    }
}
NFT
    write_file($in, $source);
    is((prepare($id, $in, $out))[0], 0, "VM $id candidate generated");
    is(read_file($in), $source, 'source is unchanged');
    my $patched = read_file($out);
    like($patched, qr/ct state established ct direction reply/, 'reply direction is explicit');
    my $expected = read_file("$FindBin::Bin/../nftables/host-ssh-replies.nft");
    ($expected) = $expected =~ /^insert rule inet cpan${id}_filter input (.+)$/m;
    my $original = $patched;
    is($original =~ s/^[ \t]*\Q$expected\E\n//m, 1, 'exact runtime rule inserted once');
    is($original, $source, 'removing the new rule restores every original byte');
    is((stat($out))[2] & 0777, 0600, 'candidate is private');

    isnt((prepare($id, $in, $out))[0], 0, 'existing output is refused');
    is(read_file($out), $patched, 'existing output is preserved');
    isnt((prepare($id, $out, "$out.again"))[0], 0, 'already configured input is refused');
    ok(!-e "$out.again", 'no duplicate candidate');

    my $changed = $source;
    $changed =~ s/policy accept/policy drop/;
    write_file("$in.changed", $changed);
    isnt((prepare($id, "$in.changed", "$out.changed"))[0], 0, 'unexpected policy is refused');
    ok(!-e "$out.changed", 'unexpected layout creates no output');

    my $changed_forward = $source;
    $changed_forward =~ s/(chain forward \{)/$1\n        # other policy retained/;
    write_file("$in.forward", $changed_forward);
    is((prepare($id, "$in.forward", "$out.forward"))[0], 0, 'forward-chain variation is retained');
    my $forward_candidate = read_file("$out.forward");
    $forward_candidate =~ s/^[ \t]*\Q$expected\E\n//m;
    is($forward_candidate, $changed_forward, 'forward/NAT variation untouched');

    symlink $in, "$in.link" or die $!;
    isnt((prepare($id, "$in.link", "$out.link"))[0], 0, 'symlink input is refused');
    symlink $in, "$out.symlink" or die $!;
    isnt((prepare($id, $in, "$out.symlink"))[0], 0, 'symlink output is refused');
    is(read_file($in), $source, 'symlink target is unchanged');

    write_file("$in.unexpected", $source =~ s/chain input/chain another/r);
    isnt((prepare($id, "$in.unexpected", "$out.unexpected"))[0], 0, 'missing input chain is refused');
    write_file("$in.duplicate", $source . $source);
    isnt((prepare($id, "$in.duplicate", "$out.duplicate"))[0], 0, 'duplicate input chains are refused');
    isnt((prepare(999, $in, "$out.wrong-id"))[0], 0, 'unsupported VM layout is refused');
}

done_testing;
