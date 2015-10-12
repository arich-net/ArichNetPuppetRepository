#!/usr/bin/perl

package NTTEU::USF::Exec;

#####################################################
# Package for handling the execution of external    #
# commands.                                         #
# v0.1 2009-08-14 cristobal.garcia@ntt.eu           #
#####################################################

use NTTEU::USF::Logger;

our $VERSION='0.5';

# shell_exec_command
# executes a command in a shell. Logs to a logger and, optionally, 
# dumps the output (stdout) to an array
# the exit code is the O/S exit status. No signal information is provided.
# Usage:
#   NTTEU::USF::Exec::shell_exec_command("command string",$reference_to_a_logger [,reference to an array]);
# Example:
#   my @command_output;
#   my $logger = new NTTEU::USF::SimpleLogger();
#   my $exit_status = NTTEU::USF::Exec::shell_exec_command("/bin/ls -la",$logger,\@command_output);
#   
#   @command_status will hold the output, line by line
#   $exit_status will hold the status code 0 = success.

sub shell_exec_command($$;$) {
	my ($cline,$logger,$output) = @_;
	my $res;
	my @tmp_output;

	$logger->debug("About to execute: $cline");
	@tmp_output = `$cline`;
	$res = $?>>8;
	$logger->debug("EXIT STATUS: $res");
	for my $out_line (@tmp_output){
		chomp($out_line);
		$logger->debug("OUTPUT: $out_line");
	}
	if (defined($output)){
		@$output = @tmp_output;
	}

	return $res;
}


1;
