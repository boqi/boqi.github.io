#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test_booksource.pl
#
#        USAGE: ./test_booksource.pl  
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
#      CREATED: 01/31/20 03:15:12
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use JSON qw/decode_json/;
my $file = shift;
$file = "booksource.json" unless($file);
open FI,'<',$file;
my $text = join("",<FI>);
close FI;
print STDERR $text,"\n";
use Data::Dumper;
print STDERR Data::Dumper->Dump([decode_json($text)],['text']),"\n";
