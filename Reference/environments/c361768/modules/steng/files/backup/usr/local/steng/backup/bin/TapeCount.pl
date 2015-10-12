#!/usr/bin/perl

#Usage /.../TapeCount.pl "PoolName"
#It returns the number of tapes inside the pool "PoolName"

use strict;
use warnings;

my $Count = 0;
my $CMD='/usr/openv/volmgr/bin/vmquery -bx -pn';
my $pool = $ARGV[0] or die("pool missing");
my $time = time;
my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
my ($sec,$min,$hour,$day,$month,$year) = (localtime($time))[0,1,2,3,4,5];
my $current_year = $year+1900;

open(RESULT,"$CMD $pool|") or die ("Cannot exec $CMD or error:$?");

while(my $line = <RESULT>){
        #print $line;
        chomp($line);
        my @parsed_line;
        #print "@parsed_line";
        if ($line !~ /HCART/){
                next;
        }
        if (@parsed_line = ($line =~ /^\w{6}\s+(\S+)\s+(\S+)\s+(\S+)/)){
                if ($parsed_line[1] ne "NONE"){
                        #print "$parsed_line[1]\n";
                        $Count = $Count+1;
                        next;
                }
        }
}
close(RESULT);
print "$day/$months[$month]/$current_year $hour:$min:$sec ";
print "$ARGV[0]:$Count\n";

exit 0
