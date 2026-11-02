#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use XML::Parser ();
use SOAP::Lite ();

# Run against the upstream checkout before and after applying the companion
# patch. XML::Parser 2.48 is known to trigger the original regression.
my $phase = shift @ARGV || die "usage: $0 baseline|patched\n";
die "unknown phase: $phase\n" unless $phase eq 'baseline' || $phase eq 'patched';

my $xml_parser_version = $XML::Parser::VERSION;
diag("phase=$phase XML::Parser=$xml_parser_version perl=$]");
my $xml = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">' .
          '<env:Body><ping>ok</ping></env:Body></env:Envelope>';

sub attempt {
    my ($document) = @_;
    my $parser = SOAP::Parser->new();
    my $ok = eval { $parser->decode($document); 1 };
    return ($ok, $@, $parser);
}

my @valid_documents = (
    ['no trailing characters', $xml, 0],
    ['trailing LF',           $xml . "\n", 1],
    ['trailing CRLF',         $xml . "\r\n", 1],
    ['trailing spaces/tabs',  $xml . " \t  ", 1],
    ['trailing mixed S',      $xml . " \r\n\t", 1],
);

for my $case (@valid_documents) {
    my ($name, $document, $has_tail) = @$case;
    my ($ok, $err, $parser) = attempt($document);
    # Both 2.48 and 2.54 are confirmed affected; 2.55 reverted the
    # underlying XML::Parser default-handler routing change.
    my %affected = map { $_ => 1 } qw(2.48 2.54);
    my $regression_expected =
        $phase eq 'baseline' && $affected{$xml_parser_version} && $has_tail;
    if ($regression_expected) {
        ok(!$ok, "$name: unpatched regression is reproduced");
        like($err, qr/non-creatable array value|subscript -1/,
             "$name: the failure is the known empty-stack exception");
    } else {
        ok($ok, "$name: valid SOAP XML parsed successfully") or diag($err);
        is(ref($parser->{_done}), 'ARRAY', "$name: root was recorded") if $ok;
    }
}

if ($phase eq 'patched') {
    for my $bad (
        ['non-whitespace after root', $xml . 'junk'],
        ['second root element',       $xml . '<extra/>'],
    ) {
        my ($ok, $err) = attempt($bad->[1]);
        ok(!$ok, "$bad->[0]: invalid XML remains rejected");
        ok(length($err) > 0, "$bad->[0]: error is reported");
    }
}
done_testing();
