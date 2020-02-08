#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: json2.pl
#
#        USAGE: ./json2.pl  
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
#      CREATED: 02/08/20 05:46:30
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use JSON;
my $js = JSON->new();

foreach my $file(@ARGV) {
	my $output = $file;
	$output =~ s/.*\///;
	if($output eq $file) {
		print STDERR "Error IO same file:$output ...\n";
		next;
	}
	if(!open FI,'<',$file) {
		print STDERR "Error reading $file ...\n";
		next;
	}
	my $oldtext = join("",<FI>);
	close FI;
	my $o = $js->decode($oldtext);
	if(!$o) {
		print STDERR "Error decoding $file ...\n";
		next;
	}
	if(ref $o eq 'HASH') {
		$o = [$o];
	}
	open FO,">",$output or die("$!\n");
	foreach my $js (@$o) {
		if($js->{exploreUrl}) {
			$js->{ruleFindUrl} = $js->{exploreUrl};
			delete $js->{exploreUrl};
			$js->{ruleFindUrl} =~ s/{{key}}/searchKey/g;
			$js->{ruleFindUrl} =~ s/{{page}}/searchPage/g;
		}
		if($js->{ruleBookInfo}) {
			my $j = $js->decode($js->{ruleBookInfo});
			$js->{ruleBookName} = $j->{name};
			$js->{ruleBookAuthor} = $j->{author};
		}
	}
}
