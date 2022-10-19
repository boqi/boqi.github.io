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

my $text;
while(<>) {
	chomp;
	s/&amp;/&/g;
	$text = $text . $_;
}
my $style='{"layout_flexGrow":0,"layout_wrapBefore": false}';
print "[\n";
	while($text =~ m/href\s*=\s*(['"])(.+?)\1[^>]*>(.+?)<\/a/g) {
		#		print join("\n","1:$1","2:$2","3:$3"),"\n";
		my $u = $2;
		my $t = $3;
		$t =~ s/<[^>]*>//g;
		print "{\"title\":\"$3\",\"url\":\"$u\",\"style\":$style},\n"
	}
print "]\n";
