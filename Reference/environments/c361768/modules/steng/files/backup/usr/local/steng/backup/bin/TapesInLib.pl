#!/usr/bin/perl

#Usage /.../TapesInLib.pl "RoboNumber"
#It returns the number of tapes inside the library with number "RoboNumber"

use strict;
use warnings;

my $count = 0;
my $CMD='/usr/openv/volmgr/bin/vmquery -b -a';
my $time = time;
my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
my ($sec,$min,$hour,$day,$month,$year) = (localtime($time))[0,1,2,3,4,5];
my $current_year = $year+1900;

open(RESULT,"$CMD|") or die ("Cannot exec $CMD or error:$?");

while(my $line = <RESULT>){
        chomp($line);
        my @parsed_line;
        if ($line !~ /TLD/){
                next;
        }
        if (@parsed_line = ($line =~ /^\w{6}\s+(\S+)\s+(\S+)\s+(\S+)/)){
                if ($parsed_line[2] eq $ARGV[0]){
                        $count = $count+1;
                        next;
                }
        }
}
close(RESULT);
print "$day/$months[$month]/$current_year $hour:$min:$sec ";
print "$ARGV[0]:$count\n";
exit 0
