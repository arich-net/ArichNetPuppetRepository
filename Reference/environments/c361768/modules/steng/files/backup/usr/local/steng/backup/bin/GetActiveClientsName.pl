#!/usr/bin/perl

#usage: perl GetActiveClientName.pl > "output file"
#it reads from standard input an array of 3 values separated by space, whose 3rd value is clientname.
#it returns the client name in standarinput.
#result is stored in "output file"

use strict;
use warnings;

my $clientname = "";
my @result = ();
my @fields = ();
my $file = "";

while($file = <STDIN>){
	chop($file);
	@fields = split(/\s+/,$file);
	$clientname = $fields[2];
	print "$clientname\n";
	}
exit 0

