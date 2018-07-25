#!/usr/bin/perl -w
use strict;
print STDERR "Generating <opensearch.html> ...\n";


my $di;
my @files;
opendir $di,"opensearch" or die("$!\n");
foreach(readdir $di) {
	push @files,$_ if(m/\.xml$/i);
}
close $di;

my $fo;
open $fo,'>','opensearch.html' or die("$!\n");

print $fo '<head>',"\n";
foreach(@files) {
	my $n = $_;
	$n =~ s/^.*\///;
	$n =~ s/\.xml$//i;
	print STDERR "    $n ...\n";
	print $fo '<link rel="search" type="application/opensearchdescription+xml"',"\n";
	print $fo "    title=\"$n search\"\n";
	print $fo "    href=\"https://boqi.github.io/opensearch/$_\"\n";
	print $fo ">\n";
}
print $fo '</head>',"\n";
print $fo "<html>\n<body>\n<ul>\n";
foreach(@files) {
	my $url = "https://boqi.github.io/opensearch/$_";
	print $fo "<li><a href=\"$url\">$url</a></br></li>\n";
}
print $fo "</ul>\n";
print $fo '<span style="text-align:right">Last Update ' . scalar(localtime) . "</span>\n";
print $fo "</body>\n</html>\n";

close $fo;

print STDERR "[OK]\n";

exit 0;
