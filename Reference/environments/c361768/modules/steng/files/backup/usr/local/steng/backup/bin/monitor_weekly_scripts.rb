#!/bin/env jruby
#
# (C) NTTE Storage Engineering
# Check there is any weekly or monthly report script.
#
# Return 0 on STDOUT if there is NO any process active
# Return 1 on STDOUT if YES there is any process on
#

WEEKLY_PROCESS="/bin/ps -ef | egrep ly_nb_report.sh | grep -v grep"
FAILED=1
OK=0

begin
  output = %x[#{WEEKLY_PROCESS}]

  if output.lines.count > 0
    puts FAILED
  else
    puts OK
  end
end

