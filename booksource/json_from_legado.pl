#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: json_from_legado.pl
#
#        USAGE: ./json_from_legado.pl  <filenames>
#
#  DESCRIPTION: 将legado(3.0)的书源，转换为yuedu(2.0)的书源。
#               原文件应在不同的目录，否则不会执行。
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
		"\\{\\{key\\}\\}"=>"searchKey",
		"\\{\\{page\\}\\}"=>"searchPage",
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
		elsif($value =~ m/^(.+?)\s*,\s*\{(.+)\}\s*$/s){#3.0 URL
			my $baseurl = $1;
			my $header = $2;
			$header = $js->decode('{' . $header . '}');
			if($header->{method} and lc($header->{method}) eq 'post') {
				$value = $baseurl . "@" . ($header->{body} || "");
			}
			else {
				$value = $baseurl . "?" . ($header->{body} || "");
			}
			if($header->{charset}) {
				$value = $value . "|char=" . $header->{charset};
			}
		}
		$key = $conv;
	}
	if($value) {
		foreach my $exp (keys %{$CONV{TEXT}}) {
			$value =~ s/$exp/$CONV{TEXT}->{$exp}/g;
		}
	}
	$r->{$key} = $value;
	print STDERR "       \$key => $key\n";
	print STDERR "       \$value => " . ($value || "") . "\n";	
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
