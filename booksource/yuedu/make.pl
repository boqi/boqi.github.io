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


my @src1;
my @src2;
my $dst1 = "booksource.json";
my $dst2 = "booksource.json";
my $path1 = "booksource/yuedu";
my $path2 = "booksource/YiCiYuan";


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
	my $path1 = shift;
	my $dst1 = shift;
	my $prefix = shift;
	my @src1 = @_;
	my @source;
	print STDERR "Making $dst1 ...\n";
	push @text,"$index. [$dst1]($path1/$dst1)\n\n";
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
		my $line = "    * [" . $json->{bookSourceName} . "]($path1/$_)\n        for <" . $json->{bookSourceUrl} . ">\n";
		print STDERR $line;
		push @text,$line;
		push @source,$text;
	}
	push @text,"\n";
	print STDERR "Writting $dst1 ...\n";
	print FO "[\n",join(",",@source),"]\n";
	close FO;
}

merge_json("1",$path1,$dst1,@src1);
merge_json("2",$path1,$dst2,@src2);

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


