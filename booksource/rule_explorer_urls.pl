#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: x_findurls.pl
#
#        USAGE: ./x_findurls.pl  
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
#      CREATED: 02/16/20 03:24:40
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

my $use_style = shift;
my $style='{"layout_flexGrow":0,"layout_wrapBefore": false}';

my @text;
while(<STDIN>) {
	chomp;
	s/&amp;/&/g;
	push @text,$_;
}
my $text = join("\n",@text);
if($use_style) {
	print "[";
};
	while($text =~ m/href\s*=\s*(['"])(.+?)\1[^>]*>(.+?)<\/a|([^\r\n\s\f]+?)::([^\f\r\n\s]+)/g) {
		#print join("\n","1:$1","2:$2","3:$3"),"\n";
		my $u = $2;
		my $t = $3;
		if($4) {
			$t = $4;
			$u = $5;
		}
		$t =~ s/<[^>]*>//g;
		$u =~ s/\/1(\/?)$/\/{{page}}$1/;
		$u =~ s/\/1\.html$/\/{{page}}.html/;
		if($use_style) {
			print "\n{\"title\":\"$t\",\"url\":\"$u\",\"style\":$style},"
		}
		else {
			print "${t}::${u}\n";
		}
	}
if($use_style) {
	print "\b\n]\n";
}
