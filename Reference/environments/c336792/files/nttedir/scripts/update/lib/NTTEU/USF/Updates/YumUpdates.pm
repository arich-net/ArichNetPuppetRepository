package NTTEU::USF::Updates::YumUpdates;

use strict;
use warnings;
use NTTEU::USF::Logger;
use NTTEU::USF::Exec;
use NTTEU::USF::Updates;

our @ISA=qw(NTTEU::USF::Updates);

our $VERSION='0.1';

use constant CMD_OPTIONS => 'check-update';

sub new {
	my ($class,$yum,$logger) = @_;
	my $self = $class -> SUPER::new($logger);
	$self->{'_yum'} = $yum;
	return $self;
}

# re-sets / gets the yum
sub yum {
	my ($self,$yum) = @_;
	if (defined $yum) {
		$self->{'_yum'} = $yum;
	}
	return $self->{'_yum'};
}

sub get_available_updates {
	my ($self) = @_;
	my $res = [];
	my $updates = [];
	my $deps = [];
	my $logger = $self->logger;
	
	$logger->debug("starting get_available_updates");

	my $cmd = $self->yum. " ".&CMD_OPTIONS;
	my @yum_output = ();
	my $yum_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@yum_output);
	if (($yum_res != 0)&&($yum_res != 100)){
	# yum returns 100 if there are available updtes. Nice!
		$logger->error("Error executing $cmd");
		$res = 0;
		return $res;
	}

	my @yum_filtered_output = grep(/rhel/,@yum_output);
	$updates = \@yum_filtered_output;

	$res->[0] = $updates;
	$res->[1] = $deps;
	$logger->debug("finishing get_available_updates");

	return $res;

}
1;
