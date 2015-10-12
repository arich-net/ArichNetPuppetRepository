#!/usr/bin/perl
package NTTEU::USF::OSDetector;

##############################################
# UNIX OS Detection module                   #
# (c) NTTEO                                  #
# v0.1 cristobal.garcia@ntt.eu               #
##############################################
# Supported O/S                              #
# * Ubuntu 8/04 x86                          #
# * Solaris 10 sparc                         #
##############################################

#
# Usage:
# use NTTEU::USF::Logger;
# use NTTEU::USF::SimpleLogger; # or other logger
# $search_path = ['/bin','/usr/bin'];
# $logger = new NTTEU::USF::SimpleLogger;
# $osd = new NTTEU::USF::OSDetector($search_path,$logger);
# $operating_system = $osd->os
#
use strict;
use warnings;

our $VERSION='0.1';

use NTTEU::USF::Logger;
use NTTEU::USF::Exec;


# PRIVATE FUNCTION
# Finds a binary in the system using the path defined in the search_path attribute
sub _find_bin {
	my ($self,$bin_to_find) = @_;
	my $res = 0;

	my $search_path = $self->{'_search_path'};
	for my $item (@$search_path){
		if (-x "$item/$bin_to_find") {
			$res = "$item/$bin_to_find";
			last;
		}
	}
	return $res;
}

# PRIVATE FUNCTION
sub _get_uname_path{
	my ($self) = @_;
	my $res = $self->_find_bin("uname");
	$self->logger->debug("Find uname: $res");
	return $res;
}

# PRIVATE FUNCTION
sub _get_lsb_release_path {
	my ($self) = @_;
	my $res = $self->_find_bin("lsb_release");
	$self->logger->debug("Find lsb_release: $res");
	return $res;
}

# PRIVATE FUNCTION
sub _get_os {
	my ($self) = @_;
	my $logger = $self->logger;
	my $res = 0;
	my @uname_output = [];
	my $cmd = $self->uname;
	my $uname_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@uname_output);
	
	if ($uname_res != 0 ){
		$logger->error("Error executing $cmd");
		return $res;
	}
	$res = $uname_output[0];
	chomp $res;

	return $res;
}

# PRIVATE FUNCTION
sub _get_distrib {
	my ($self,$os) = @_;
	my $res = 0;
	if ($os !~ /[Ll]inux/ ){
		return $res;
	}
	my $logger = $self->logger;
	my $cmd = $self->lsb_release." -i";
	my @output = [];
	my $lsb_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@output);
	if ($lsb_res != 0){
		$logger->debug("could not execute $cmd. This could be normal");
		return $res;
	}
	$output[0] =~ /^Distributor ID:\s+(.*)$/;
	$res = $1;

	return $res;
}

# PRIVATE FUNCTION
sub _get_version {
	my ($self,$os) = @_;
	my $res = 0;
	my $logger = $self->logger;
	my $cmd = "";
	my $is_linux = $os =~ /[Ll]inux/;
	if ($is_linux){
		$cmd = $self->lsb_release . " -r";
	}else{
		$cmd = $self->uname. " -r";
	}
	my @output = [];
	my $version_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@output);
	if ($version_res != 0){
		$logger->error("Error executing $cmd");
		return $res;
	}
	if ($is_linux){
		$output[0] =~ /^Release:\s+(.*)$/;
		$res = $1;
	}else{
		$res = $output[0];
		chomp $res;
	}
	return $res;
}

# PRIVATE FUNCTION
sub _get_arch {
	my ($self,$os) = @_;
	my $res = 0;
	my $logger = $self->logger;
	my $is_linux = $os =~ /Linux/i;
	my $is_solaris = $os =~ /SunOS/i;
	my $is_freebsd = $os =~ /FreeBSD/i;
	my $cmd = "";
	if ($is_linux) {
		$cmd = $self->uname . " -m";
	}elsif ($is_solaris){
		$cmd = $self->uname . " -p";
	}elsif ($is_freebsd){
		$cmd = $self->uname . " -p";
	}else {
		$logger->error("Unsupported O/S: $os");
		return $res;
	}
	my @output = [];
	my $version_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@output);
	if ($version_res != 0){
		$logger->error("Error executing $cmd");
		return $res;
	}
	$res = $output[0];
	chomp $res;
	return $res;
}


# Creates an OSDetector instance
# Args:
# 0 class. Perl convention
# 1 reference to an array of directories: the search path
# 2 logger

sub new {
	my ($class,$search_path,$logger) = @_;
	my $self = {};
	bless($self,$class);
	$self->{'_logger'} = $logger;
	$self->{'_search_path'} = $search_path;
	$self->{'_uname'} = $self->_get_uname_path();
	$self->{'_lsb_release'} = $self->_get_lsb_release_path();
	$self->{'_os'} = $self->_get_os();
	$self->{'_version'} = $self->_get_version($self->os);
	$self->{'_distrib'} = $self->_get_distrib($self->os);
	$self->{'_arch'} = $self->_get_arch($self->os);
	$self->logger->debug("Created NTTEU::USF::OSDetector");
	return $self;
}

# re-sets / gets the logger
sub logger {
	my ($self,$logger) = @_;
	if (defined $logger){
		$self->{'_logger'} = $logger;
	}
	return $self->{'_logger'};
}

# re-sets / gets the search_path
sub search_path {
	my ($self,$search_path) = @_;
	if (defined $search_path){
		$self->{'_search_path'} = $search_path;
	}
	return $self->{'_search_path'};
}


# gets the OS string as provided by uname = Linux|FreeBSD|Solaris
# if error, returns false 
sub os {
	my ($self) = @_;
	return $self->{'_os'};
}

# gets the OS distribution as provided by lsb_release = Ubuntu | Debian | ...
# if error, returns false. For non-linux systems, returns false
sub distrib {
	my ($self) = @_;
	return $self->{'_distrib'};
}

# gets the OS version for non-linux systems and the Distribution version
# for linux versions
# If errors, returns false
sub version {
	my ($self) = @_;
	return $self->{'_version'};
}

# gets the arch for all systems in a best-effort way
# current values have been i386, i686, sparc
sub arch {
	my ($self) = @_;
	return $self->{'_arch'};
}

# gets the uname path as determined by the constructor
sub uname {
	my ($self) = @_;
	return $self->{'_uname'};
}

# gets the lsb_release path as determined by the constructor. 
# This has no point for non-linux systems
sub lsb_release {
	my ($self) = @_;
	return $self->{'_lsb_release'};
}

1;
