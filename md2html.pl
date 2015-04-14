#!/usr/bin/perl -w

my @text;
while(<>) {
	chomp;
	#s{(?:<\()(https?://[^\s]+)}{($1)}g;
	#s{(https?://[^\s]+)}{[$1]($1)}g;
	s{(?:<\(\s*)(https?://[^\s]+)}{[$1]($1)}g;
	push @text,$_;
}

use Text::Markdown qw/markdown/;
print markdown(join("\n",@text));


