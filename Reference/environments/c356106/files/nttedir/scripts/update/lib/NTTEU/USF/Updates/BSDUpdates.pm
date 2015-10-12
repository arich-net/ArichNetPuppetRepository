#
# Used for BSD patch management
#

package NTTEU::USF::Updates::BSDUpdates;

use strict;
use warnings;
use NTTEU::USF::Logger;
use NTTEU::USF::Exec;
use NTTEU::USF::Updates;

our @ISA=qw(NTTEU::USF::Updates);

use constant CMD_OPTIONS_PORTSNAP => '-I update';
use constant CMD_OPTIONS_PKGVERSION => '-vIL \'=>\'';

sub new {
	my ($class,$portsnap,$pkgversion,$logger) = @_;
	my $self = $class->SUPER::new($logger);
	$self->{'_portsnap'} = $portsnap;
	$self->{'_pkgversion'} = $pkgversion;
	return $self;
}

sub portsnap {
	my ($self) = @_;
	return $self->{'_portsnap'};
}

sub pkgversion {
	my ($self) = @_;
	return $self->{'_pkgversion'};
}

sub get_available_updates {
	my ($self) = @_;
	my $res = [];
	my $updates = [];
	my $logger = $self->logger;

	$logger->debug("starting to update the ports tree");
	my $portsnap_cmd = $self->portsnap." ".&CMD_OPTIONS_PORTSNAP;
	my $portsnap_res = NTTEU::USF::Exec::shell_exec_command($portsnap_cmd,$logger);
	if ($portsnap_res != 0){
		$logger->error("Error executing $portsnap_cmd");
		$res = 0 ;
		return $res;
	}
	$logger->debug("ports tree updated");
	$logger->debug("starting get_available_updates");
	my $cmd = $self->pkgversion. " ".&CMD_OPTIONS_PKGVERSION;
	my @bsd_output = ();
	my $bsd_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@bsd_output);
	if ($bsd_res != 0){
		$logger->error("Error executing $cmd");
		$res = 0;
		return $res;
	}

	$updates = \@bsd_output;

	$res->[0] = $updates;
	$logger->debug("finishing get_available_updates");

	return $res;

}
1;

