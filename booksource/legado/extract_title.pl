#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: extract_topiclist.pl
#
#        USAGE: ./extract_topiclist.pl  
#
#  DESCRIPTION: Extract topics from URLS like:http://www.hehua2.com/topiclist/1.html 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Eotect Nahn (eote), eotect@myplace.hel
# ORGANIZATION: MyPlace HEL ORG.
#      VERSION: 1.0
#      CREATED: 2022/10/23  2:45:37
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use MyPlace::WWW::Utils qw/get_url htmlcontent_to_text/;

my $template = shift;
my $content_regex = shift;

my $page = 1;
while($page) {
	my $url = $template;
	$url =~ s/\{\{page\}\}/$page/g;
	my $html = get_url($url,"-v");
	if($content_regex) {
		if($html =~ m/$content_regex/ms) {
			$html = $1;
		}
		else {
			$html = "";
			print STDERR "NOT MATCH /$content_regex/\n";
		}
	}
	my $match;
	my @title;
	foreach(qw/title h1 h2 h3 h4/) {
		if($html =~ m/<$_>(.+?)<\/$_>/) {
			my $t = $1;
			next if($t =~ m/404 Not Found/);
			next if($t =~ m/网站正在维护中/);
			push @title,htmlcontent_to_text($t);
			$match = 1;
		}
	}
	print join(",",@title) . "::" . $url . "\n" if(@title);
	last if($url eq $template);
	$page = $match ? ($page+1) : 0;
}
