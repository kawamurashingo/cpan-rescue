#!/usr/bin/env perl
use strict;
use warnings;
use SOAP::Lite ();
use XML::Parser ();
use Data::Dumper ();

my $phase = shift(@ARGV) || 'unknown';
print "phase=$phase XML::Parser=$XML::Parser::VERSION perl=$]\n";
my $implementation = SOAP::Deserializer->parser->parser;
print 'backend=' . ref($implementation) . "\n";

sub show {
    my ($label, $expr) = @_;
    my ($got, $error);
    $got = eval { $expr->() };
    $error = $@ || '';
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Useqq = 1;
    print "$label result=" . Data::Dumper::Dumper($got);
    print "$label error=" . Data::Dumper::Dumper($error);
}
show('CDATA', sub {
    SOAP::Deserializer->deserialize('<root><![CDATA[<123>]]></root>')->root;
});
show('EXTERNAL_ENTITY', sub {
    SOAP::Deserializer->deserialize(
        '<?xml version="1.0"?><!DOCTYPE foo [ <!ENTITY ll SYSTEM "foo.txt"> ]><root>&ll;</root>'
    )->root;
});
show('VALID_TEXT', sub {
    SOAP::Deserializer->deserialize('<root>hello</root>')->root;
});
