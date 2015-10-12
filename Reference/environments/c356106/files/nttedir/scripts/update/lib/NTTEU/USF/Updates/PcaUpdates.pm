package NTTEU::USF::Updates::PcaUpdates;

use strict;
use warnings;
use NTTEU::USF::Logger;
use NTTEU::USF::Exec;
use NTTEU::USF::Updates;

our @ISA=qw(NTTEU::USF::Updates);

use constant CMD_OPTIONS => '--noheader -l missings';
use constant PCA_UPDATE_OPTIONS => '--update=now';

sub new {
	my ($class,$pca_path,$logger) = @_;
	my $self = $class -> SUPER::new($logger);
	$self->{'_pca'} = $pca_path;
	return $self;
}

sub pca {
	my ($self) = @_;
	return $self->{'_pca'};
}

sub get_available_updates {
	my ($self) = @_;
	my $res = [];
	my $updates = [];
	my $deps = [];
	my $logger = $self->logger;
	
        $logger->debug("starting get_available_updates");

        $logger->debug("  checking for/applying updates to the patching tool pca (http://www.par.univie.ac.at/solaris/pca/)");
        my $pca_updatecmd = $self->pca. " ".&PCA_UPDATE_OPTIONS;
        my @pca_update_output = ();
        my $pca_update_res = NTTEU::USF::Exec::shell_exec_command($pca_updatecmd,$logger,\@pca_update_output);
        if ($pca_update_res != 0){
                $logger->error("  Error executing $pca_updatecmd");
                $res = 0;
                return $res;
        }

	$logger->debug("  checking for available security updates and dependencies");
	my $cmd = $self->pca. " ".&CMD_OPTIONS;
	my @pca_output = ();
	my $pca_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@pca_output);
	if ($pca_res != 0){
		$logger->error("  Error executing $cmd");
		$res = 0;
		return $res;
	}

	$updates = \@pca_output;

	$res->[0] = $updates;
	$res->[1] = $deps;
	$logger->debug("finishing get_available_updates");

	return $res;

}
1;
