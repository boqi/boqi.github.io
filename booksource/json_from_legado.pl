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

my %CONV = (
	"TEXT" => {
		"{{key}}"=>"searchKey",
		"{{page}}"=>"searchPage",
	},
	"header" => {
		"User-Agent" => "httpUserAgent",
	},
	"exploreUrl" => "ruleFindUrl",
	"ruleBookInfo" => {
		"author"=>"ruleBookAuthor",
		"coverUrl"=>"ruleCoverUrl",
		"intro"=>"ruleIntroduce",
		"kind" =>"ruleBookKind",
		"lastChapter" => "ruleBookLastChapter",
		"name"=>"ruleBookName",
	},
	"ruleContent" => {
		"content" => "ruleBookContent",
		"nextContentUrl" => "ruleContentUrlNext",
	},
	"ruleExplorer" => {
		"bookList" => "ruleFindList",
		"bookUrl" => "ruleFindNoteUrl",
		"coverUrl" => "ruleFindCoverUrl",
		"intro" => "ruleFindIntroduce",
		"kind" => "ruleFindKind",
		"lastChapter" => "ruleFindLastChapter",
		"name" => "ruleFindName",
	},
	"ruleSearch" => {
		"bookList" => "ruleSearchList",
		"bookUrl" => "ruleSearchNoteUrl",
		"coverUrl" => "ruleSearchCoverUrl",
		"kind" => "ruleSearchKind",
		"lastChapter" => "ruleSearchLastChapter",
		"name" => "ruleSearchName",
		"intro" => "ruleSearchIntroduce",
	},
	"ruleToc" => {
		"chapterList" => "ruleChapterList",
		"chapterUrl" => "ruleContentUrl",
		"chapterName" => "ruleChapterName",
		"nextChapterUrl" => "ruleContentUrlNext",
	},
	"searchUrl" => "ruleSearchUrl", 
);

sub convert {
	my $r = shift;
	my $key = shift;
	my $value = shift;
	my $conv = $CONV{$key};
	print STDERR "   Converting <$key>\n";
	if($conv) {
		my $t = ref $conv;
		if($t eq 'HASH') {
			print STDERR "----------------------------------------------\n";
			print STDERR "$value,n";
			print STDERR "----------------------------------------------\n";
			$value = $js->decode($value);
			foreach(keys %$conv) {
				convert($r,$conv->{$_},$value->{$_});
			}
			return;
		}
		else {
			$value =~ s/\{\{key\}\}/searchKey/g;
			$value =~ s/\{\{page\}\}/searchPage/g;
			$r->{$conv} = $value;
		}
	}
	else {
		if($value) {
			$value =~ s/\{\{key\}\}/searchKey/g;
			$value =~ s/\{\{page\}\}/searchPage/g;
		}
		$r->{$key} = $value;
	}
	print STDERR "       \$key => $key\n";
	print STDERR "       \$value => $value\n";	
}



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
	print STDERR "Processing $output ...\n";
	my $new = [];
	foreach my $js (@$o) {
		print STDERR "  Converting " . $js->{bookSourceName} . " ...\n";
		my $jsnew = {};
		foreach my $key(keys %$js) {
			convert($jsnew,$key,$js->{$key});
		}
		push @$new,$jsnew;
	}
	print FO $js->pretty->encode($new);
	print STDERR "OK\n";
	close FO;
}
