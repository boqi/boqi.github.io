#!/usr/bin/perl -w

my @text;
while(<>) {
	chomp;
	#s{(?:<\()(https?://[^\s]+)}{($1)}g;
	#s{(https?://[^\s]+)}{[$1]($1)}g;
	#s{(?<!\]\()(https?://[^\s]+)}{[$1]($1)}g;
	s{(https?://[^\s]+)}{<a href="$1">$1</a>}g;
	push @text,$_;
}

use Text::Markdown qw/markdown/;
#print markdown(join("\n",@text));

print markdown(join("<BR/>\n",@text));


