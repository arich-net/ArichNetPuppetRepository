#!/bin/env jruby
#
# (C) NTTE Storage Engineering
# Check the OST disks status to the STDOUT
#
# Puts a 0 on STDOUT if everything is ok, any other thing
# if there are errors
#

OST_STATUS="/usr/openv/netbackup/bin/admincmd/nbdevquery -listdv -stype SEPATON -U | egrep DOWN"
FAILED=1
OK=0

result = OK
begin
  output = %x[#{OST_STATUS}]
  status = $?

  if status.exitstatus == 0
    result = FAILED
  end
end

puts result
