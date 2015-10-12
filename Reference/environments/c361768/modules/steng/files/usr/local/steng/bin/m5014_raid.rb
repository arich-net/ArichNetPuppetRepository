#!/bin/env jruby
#

# Puts a 0 on STDOUT if everything is ok, any other thing
# if there are errors
#

MEGARAID_TEST="/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -Lall -aALL 2>&1"
OTHER_FAILURE=256

begin
  output = %x[#{MEGARAID_TEST}]
  status = $?

  if status.exitstatus != 0
    puts OTHER_FAILURE
  else
    puts output.split(/$/).grep(/State\s+:\s+Degraded/i).size
  end
rescue 
  puts OTHER_FAILURE
end
