#!/usr/bin/perl

#Usage: cat "input" | perl FullRestartJobs.pl > "output file"
#It reads a file with a list of strings.
#Each string has values separated by spaces, 1st value must be a policy name, 2nd value must be a Schedule Name and 3rd value must be a Client Server Name
#The three paramethers must exist and be coehrent to netbackup policy database.
#Result is stored in "output file"

use strict;
use warnings;
my @fields = ();
my $file = "";
my $PolicyName = "";
my $ScheduleName = "";
my $ServerName = "";
my $result = "";

while($file = <STDIN>){
        chop($file);
        @fields = split(/\s+/,$file);
        $PolicyName = $fields[0];
        $ScheduleName = $fields[1];
        $ServerName = $fields[2];
        $result = `echo /usr/openv/netbackup/bin/bpbackup -i -p $PolicyName -h $ServerName -s $ScheduleName 2>&1`;
        `/usr/openv/netbackup/bin/bpbackup -i -p $PolicyName -h $ServerName -s $ScheduleName 2>&1`;
        print "POLICY $PolicyName\n";
        print "SCHEDULE $ScheduleName\n";
        print "CLIENT $ServerName\n";
        print "$result\n";
        print "\n";
        }
exit 0

