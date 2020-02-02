#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: make.pl
#
#        USAGE: ./make.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Eotect Nahn (eotect), eotect@myplace.hel
# ORGANIZATION: MyPlace HEL. ORG.
#      VERSION: 1.0
#      CREATED: 02/03/20 01:27:28
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use MyPlace::Json qw/decode_json/;


my @src1;
my @src2;
my $dst1 = "booksource.json";
my $dst2 = "picsource/picsource.json";


my $wd = $0;
$wd =~ s/\/[^\/]+$/\//;
$wd = "" if($wd !~ m/\//);
chdir($wd) if($wd);

foreach(glob("*.json")) {
	push @src1,$_ unless($_ eq "booksource.json");
}
foreach(glob("picsource/*.json")) {
	push @src2,$_ unless($_ eq "picsource/picsource.json");
}

my @text;

sub merge_json {
	my $index = shift;
	my $dst1 = shift;
	my @src1 = @_;
	my @sources;
	print STDERR "Making $dst1 ...\n";
	push @text,"#. [$dst1](booksource/$dst1)\n\n";

	open FO,">",$dst1 or die("$!\n";
	foreach(@src1) {
		if(!open FI,"<",$_) {
			print STDERR "Error reading $_ [SKIP IT]\n";
			next;
		}
		my $text = join("",<FI>);
		close FI;
		my $json = decode_json($text);
		if(!$json) {
			print STDERR "Error found in $_ [SKIP IT]\n";
			next;
		}
		if((ref $json) eq "HASH") {
			print STDERR "No group by [], fixed it";
			if(!open FO2,">",$_) {
				print STDERR "Error writting $_ [SKIP IT]\n";
				next;
			}
			print FO2 "[" . $text . "]";
			close FO2;
		}
		else {
			$json = $json->[0];
			$text =~ s/^\s*\[//m;
			$text =~ s/\]\s*$//m;
		}
		print STDERR "Processing $_ ...\n";
		my $line = "    * [" . $json->{bookSourceName} . "]($dst1/$_)\n        for <" . $json->{bookSourceUrl} . ">\n";
		print STDERR $line;
		push @text,$line;
		push @source,$text;
	}
	print STDERR "Writting $dst1 ...\n";
	print FO "[\n",join(",",@source),"\n]\n";
	close FO;
}

merge_json("1",$dst1,@src1);
merge_json("2",$dst2,@src2);

my $text = join("",@text);
my $md = "booksource.md";
my $template = "template.md";
print STDERR "Writting $md ...\n";
print STDERR "Reading $template ... \n";
my $template = "";
if(open FI,"<",$template) {
	$template = join("",<FI>);
	close $template;
	close FI;
}
$template =~ s/#####MY BOOKSOURCE#####/$text/;
open FO,">",$md;
print FO $template;
close FO;

print STDERR "OK\n";



