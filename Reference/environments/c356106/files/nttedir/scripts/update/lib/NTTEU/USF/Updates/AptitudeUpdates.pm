package NTTEU::USF::Updates::AptitudeUpdates;

use strict;
use warnings;
use NTTEU::USF::Logger;
use NTTEU::USF::Exec;
use NTTEU::USF::Updates;

our @ISA=qw(NTTEU::USF::Updates);

our $VERSION='0.1';

#------------------------------------------------------------------------------------
#Change of 2013-02-19
#use constant CMD_OPTIONS => '-F \'%p\' search \'~U\'';
use constant CMD_OPTIONS => '-F \'%p|%v|%V|%P|%d\' search \'~U\' --sort \'name\'';
#------------------------------------------------------------------------------------

sub new {
	my ($class,$tool,$logger) = @_;
	my $self = $class -> SUPER::new($logger);
	$self->{'_tool'} = $tool;
	return $self;
}

# re-sets / gets the tool
sub tool {
	my ($self,$tool) = @_;
	if (defined $tool) {
		$self->{'_tool'} = $tool;
	}
	return $self->{'_tool'};
}

sub get_available_updates {
	my ($self) = @_;
	my $res = [];
	my $updates = [];
	my $deps = [];
	my $logger = $self->logger;
	
	$logger->debug("starting get_available_updates");

	my $cmd = $self->tool. " ".&CMD_OPTIONS;
	my @aptitude_output = ();
	my $aptitude_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@aptitude_output);
	if ($aptitude_res != 0){
		$logger->error("Error executing $cmd");
		$res = 0;
		return $res;
	}

	$updates = \@aptitude_output;

	$res->[0] = $updates;
	$res->[1] = $deps;
	$logger->debug("finishing get_available_updates");

	return $res;

}
1;
