#!/usr/bin/perl

#Usage: perl ListJobId.pl > "output file"
#Reads from standard input an array of values separated by space, whose 1st value is JobId.
#It returns JobId list.
#Result is stored in "output file"

use strict;
use warnings;
my $JobId = "";
my @fields = ();
my $file = "";

while($file = <STDIN>){
        chop($file);
        @fields = split(/\s+/,$file);
        $JobId = $fields[0];
        print "$JobId\n";
        }
exit 0

