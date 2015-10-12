#!/usr/bin/perl

#Usage: perl ListJobInfo.pl > "output file"
#Usage: /usr/openv/netbackup/bin/admincmd/bpdbjobs -report -noheader | egrep 'Active|Queued' | ListJobInfo.pl
#Reads from standard input an array of values separated by space, whose 1st value is JobId, 2nd is backup type, 4th policy name, 5th schedule name, 6thserver name
#This fits witht he output of the command /usr/openv/netbackup/bin/admincmd/bpdbjobs -report -noheader | egrep 'Active|Queued'
#Suggested usage: /usr/openv/netbackup/bin/admincmd/bpdbjobs -report -noheader | egrep 'Active|Queued' | /.../ListJobInfo.pl > /.../"output file"
#It returns a string with the following values separated by a space: Policy name, Schedule Name, Server Name and JobID.
#Result is stored in "output file"

use strict;
use warnings;
my @fields = ();
my $file = "";
my $PolicyName = "";
my $ScheduleName = "";
my $ServerName = "";
my $Type = "";
my $JobId = "";


while($file = <STDIN>){
        chop($file);
        @fields = split(/\s+/,$file);
        $JobId = $fields[0];
        $Type = $fields[1];
        $PolicyName = $fields[3];
        $ScheduleName = $fields[4];
        $ServerName = $fields[5];
        if ($fields[1] eq 'Backup')
                {
                if ($ScheduleName !~ m/^-/ && $ScheduleName !~ m/Default-Application-Backup/)
                        {
                        print "$PolicyName ";
                        print "$ScheduleName ";
                        print "$ServerName ";
                        print "$JobId\n";
                        }
                }
        }
exit 0

