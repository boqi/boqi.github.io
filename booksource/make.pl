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

use MyPlace::JSON qw/decode_json/;

my @dirs = (["yuedu","阅读2.0"],["legado","阅读3.0"],["YiCiYuan","异次源"]);


my $wd = $0;
$wd =~ s/\/[^\/]+$/\//;
$wd = "" if($wd !~ m/\//);
chdir($wd) if($wd);

my @text;

sub merge_json {
	my $index = shift;
	my $path1 = shift;
	my $name = shift;
	my $prefix = shift;
	
	my $dst1 = "$path1/booksource.json";

	print STDERR "Making $dst1 ...\n";
	push @text,"$index. [$name]($prefix/$dst1)\n\n";

	my @src1;
	foreach(glob("$path1/*.json")) {
		next if(m/$dst1/i);
		push @src1,$_;
	}

	if(!@src1) {
		print STDERR "Nothing found in $path1\n";
		return;
	}

	my @source;
	open FO,">",$dst1 or die("$!\n");
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
			print FO2 "[" . $text . "]\n";
			close FO2;
		}
		else {
			$json = $json->[0];
			$text =~ s/^\s*\[//m;
			$text =~ s/\]\s*$//m;
		}
		print STDERR "Processing $_ ...\n";
		my $line = "    * [" . $json->{bookSourceName} . "]($prefix/$_)\n        for <" . $json->{bookSourceUrl} . ">\n";
		print STDERR $line;
		push @text,$line;
		push @source,$text;
	}
	push @text,"\n";
	print STDERR "Writting $dst1 ...\n";
	print FO "[\n",join(",",@source),"]\n";
	close FO;
}


my $idx = 0;
foreach(@dirs) {
	$idx++;
	merge_json($idx,$_->[0],$_->[1],"booksource");
}

my $text = join("",@text);
my $md = "booksource.md";
my $template = "template.md";
print STDERR "Writting $md ...\n";
print STDERR "Reading $template ... \n";
my $template_text = "";
if(open FI,"<",$template) {
	$template_text = join("",<FI>);
	close $template;
	close FI;
}
$template_text =~ s/#####MY BOOKSOURCE#####/$text/;
open FO,">",$md;
print FO $template_text;
close FO;

print STDERR "OK\n";
print STDERR "Coping to ../$md ...\n";
system("cp","-av","--",$md,"../$md");


