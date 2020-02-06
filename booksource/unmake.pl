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
use JSON;
my $JSON = JSON->new();



my $wd = $0;
$wd =~ s/\/[^\/]+$/\//;
$wd = "" if($wd !~ m/\//);
chdir($wd) if($wd);

sub unmerge_json {
	my $path = shift;
	my $json_file = shift;
	$json_file = $path . "/" . $json_file;
	if((!-f $json_file) or (!open FI,'<',$json_file)) {
		print STDERR "Error reading file: <$json_file>\n";
		return undef;
	};
	my $data = join("",<FI>);
	close FI;
	my $json = $JSON->decode($data);
	if(!$json) {
		print STDERR "Error parsing file: <$json_file>\n";
		return undef;
	}
	my $type = ref $json;
	if($type eq 'HASH') {
		$json = [$json];
	}

	foreach my $s (@$json) {
		my $g = $s->{bookSourceGroup};
		my $n = $s->{bookSourceName};
		my $u = $s->{bookSourceUrl};
		next unless($g =~ m/Sesadit/i);
		my $output = $u;
		$output =~ s/^https?:\/\///i;
		$output =~ s/^w+\.([^\/]+)\.(.+)/$1.$2/;
		$output =~ s/\//_/g;
		$output =~ s/_+$//;
		$output =~ s/[\s#\?\:]+//g;
		$output = $output . ".json";
		print STDERR "$json_file :\n";
		print STDERR "    extracting $n <$output> [$g] from $json_file ...\n";
		if(!open FO,">",$output) {
			print STDERR "Error writting file: <$output>\n";
			next;
		}
		print FO "[\n";
		print FO $JSON->pretty->encode($s);
		print FO "]\n";
	}
}

unmerge_json("backups","myBookSource.json");
unmerge_json("picsource/backups","myBookSource.json");


