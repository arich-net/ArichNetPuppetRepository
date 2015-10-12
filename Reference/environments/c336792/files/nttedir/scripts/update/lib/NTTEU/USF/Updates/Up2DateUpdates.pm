package NTTEU::USF::Updates::Up2DateUpdates;

use strict;
use warnings;
use NTTEU::USF::Logger;
use NTTEU::USF::Exec;
use NTTEU::USF::Updates;

our @ISA=qw(NTTEU::USF::Updates);

our $VERSION='0.1';

use constant CMD_OPTIONS => '--nox --list';


#PRIVATE 
# Returns the expected result for get_available_updates
sub _parse_output {
	my ($self,$output) = @_;

	my $upds = [];
	my $deps = [];
	my $res = [];

	my $logger = $self->logger;

	$logger->debug("Parsing output. Skipping headers");

	my $headers_still = 1;
	my $line = shift(@$output);

	while ((defined $line)&&($headers_still)){
		if ($line =~ /^\s*-+\s*$/){
			$headers_still = 0;
		}
		$line = shift(@$output);
	}

	$logger->debug("Headers skipped. Still ".scalar(@$output)." lines to process");

	for $line (@$output) {
		chomp($line);
		if((!$line)||($line =~ /^\s*$/)){
			$logger->debug("Got a blank line. This is the end of the update list");
			last;
		}
		$logger->debug("Not a blank line: $line");
		push(@$upds,shift(@$output));
	}

	$res->[0] = $upds;
	$res->[1] = $deps;

	return($res);
}

	

sub new {
	my ($class,$up2date,$logger) = @_;
	my $self = $class -> SUPER::new($logger);
	$self->{'_up2date'} = $up2date;
	return $self;
}

# re-sets / gets the up2date
sub up2date {
	my ($self,$up2date) = @_;
	if (defined $up2date) {
		$self->{'_up2date'} = $up2date;
	}
	return $self->{'_up2date'};
}


sub get_available_updates {
	my ($self) = @_;
	my $res = [];

	my $logger = $self->logger;
	
	$logger->debug("starting get_available_updates");

	my $cmd = $self->up2date." ".&CMD_OPTIONS;
	my @up2date_output = ();
	my $up2date_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@up2date_output);
	if ($up2date_res != 0){
		$logger->error("Error executing $cmd");
		$res = 0;
		return $res;
	}
	$logger->debug("finishing get_available_updates");
	$res = $self->_parse_output(\@up2date_output);
	return $res;
}
1;
