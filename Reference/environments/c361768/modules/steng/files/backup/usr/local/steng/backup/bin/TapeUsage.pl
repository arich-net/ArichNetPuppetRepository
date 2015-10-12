#!/usr/bin/perl

#Usage /.../TapeUsage.pl "first letter of dc virtual tapes"
#It returns  a string of 4 numbers.
#first number is current number of full tapes (onsite and offsite)
#second number is average usage of all full medias in GB
#third number is full tapes of the last week
#forth value is the average usage in GB of last week's fulls
#only tapes starting with no "first letter of dc virtual tapes" are calculated

use strict;
use warnings;

my $count = 0;
my $total = 0;
my $avg = 0;
my $recent_avg = 0;
my $recent_total = 0;
my $recent_count = 0;
my $CMD='/usr/openv/netbackup/bin/admincmd/bpmedialist -mlist -l';
my $time = time;
my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
my ($sec,$min,$hour,$day,$month,$year) = (localtime($time))[0,1,2,3,4,5];
my $current_year = $year+1900;

open(RESULT,"$CMD|") or die ("Cannot exec $CMD or error:$?");

while(my $line = <RESULT>){
        chomp($line);
        my @parsed_line;
        my $hexval = 0;
        if (@parsed_line = split(/\s+/,$line)) {
                my $media_status = $parsed_line[14];
                my $is_full = $media_status & 8;
                my $tape = $parsed_line[0];
                if ($is_full){
                        if ($tape !~ /^$ARGV[0]\w{5}/){
                                $count = $count+1;
                                $total = $total + $parsed_line[8];
                                        if ($time <= ($parsed_line[5]+604800)){
                                                $recent_count = $recent_count+1;
                                                $recent_total = $recent_total+$parsed_line[8];
                                        }
                        }
                }
        }
}
close(RESULT);

### Modified 31-03-2014 due bug when count=0.
if ($count == 0){
        $count = 1;
}

$avg = ($total / $count)/(10**6);
if ($recent_total < 1){
	$recent_avg = 0;
}else{
$recent_avg = ($recent_total / $recent_count)/(10**6);
}
print "$day/$months[$month]/$current_year $hour:$min:$sec ";
print "Full:$count ";
print "Average:$avg ";
print "Last Week Fulls:$recent_count ";
print "Last Week Average:$recent_avg\n";
exit 0

