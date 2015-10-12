# SVN : $Id: ESXUpdates.pm 114 2009-12-08 16:58:15Z cgarcia $
# Copyright 2008-2009 Francois Lacroix 
# Francois Lacroix <francois.lacroix@ntt.eu>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
#

package NTTEU::USF::Updates::ESXUpdates;

use strict;
use warnings;
use NTTEU::USF::Logger;
use NTTEU::USF::Exec;
use NTTEU::USF::Updates;

our @ISA=qw(NTTEU::USF::Updates);

#use constant ESX_UPDATE => 'esxupdate -d http://euw0800121.eu.verio.net:888/3.5.0/ scan';

sub new {
	my ($class,$esxupdate,$repo_url,$logger) = @_;
	my $self = $class -> SUPER::new($logger);
	$self->{'_esxupdate'} = $esxupdate;
	$self->{'_repo_url'} = $repo_url;
	return $self;
}

sub esxupdate {
	my ($self) = @_;
	return $self->{'_esxupdate'};
}

sub repo_url {
	my ($self)= @_;
	return $self->{'_repo_url'};
}

sub get_available_updates {
	my ($self) = @_;
	my $res = [];
	my $updates = [];
	my $deps = [];
	my $logger = $self->logger;
	
        $logger->debug("starting get_available_updates");

	$logger->debug("  checking for available updates");
	#my $cmd = &ESX_UPDATE;
	my $cmd = $self->esxupdate." -d ".$self->repo_url." scan";
	my @ESX_output = ();
	my $ESX_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@ESX_output);
	if ($ESX_res != 0){
		$logger->error("  Error executing $cmd");
		$res = 0;
		return $res;
	}

	# man esxupdate "Scanning the depot"
	my @ESX_update = ();
	foreach (@ESX_output) {
		if ($_ =~ /--------/) {
			push(@ESX_update, $_);
		}
	}

	$updates = \@ESX_update;

	$res->[0] = $updates;
	$res->[1] = $deps;
	$logger->debug("finishing get_available_updates");

	return $res;

}
1;

