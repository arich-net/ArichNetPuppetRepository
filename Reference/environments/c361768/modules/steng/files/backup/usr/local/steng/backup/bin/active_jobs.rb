#!/bin/env jruby
#
# vim: ts=2:smarttab:sw=2
# 
# (C) NTTE Storage Engineering
# Puts the number of queued jobs to the STDOUT
#
#
CMD='/usr/openv/netbackup/bin/admincmd/bpdbjobs'
OPTS='-summary -noheader -ignore_parent_jobs'

cmd = "%s %s" % [CMD,OPTS]

out = %x{#{cmd}}

puts out.split(" ")[3]

