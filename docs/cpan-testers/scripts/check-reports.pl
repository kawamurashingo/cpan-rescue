#!/usr/local/bin/perl
use strict;
use warnings;
use Test::Reporter;
my $dir = shift @ARGV // '/home/cpansmoke/reports';
die "usage: $0 [directory]\n" if @ARGV;
die "not a directory: $dir\n" unless -d $dir;
my @files = sort(glob("$dir/*.rpt"), glob("$dir/hold/*.rpt"));
die "no .rpt files found\n" unless @files;
my $failed = 0;
for my $file (@files) {
    my $report = eval { Test::Reporter->new->read($file) };
    if (!$report || $@) {
        warn "READ FAILED: $file: " . ($@ || 'no report') . "\n";
        $failed++;
        next;
    }
    print "Distribution: ", $report->distribution, "\n";
    print "Grade: ", $report->grade, "\n";
    print "Subject: ", $report->subject, "\n";
    print "---\n";
}
exit($failed ? 1 : 0);
