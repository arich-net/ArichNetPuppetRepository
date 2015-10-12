package NTTEU::USF::EMail;

#####################################################
# Package for handling logging. It is the equivalent#
# of an abstract class or interface                 #
# the real job is done by classes inheriting from   #
# this one                                          #
# v0.1 2009-10-02 cristobal.garcia@ntt.eu           #
#####################################################

use strict;
use warnings;

our $VERSION='0.5';

# Params
#  $class -> convention in perl
#  $logger -> a logger
sub new {
	my ($class,$logger) = @_;
	my $self = {};
	$self->{'_logger'} = $logger;
	bless($self,$class);
	return $self;
}

sub logger {
	my ($self,$logger) = @_;
	if (defined($logger)){
		$self->{'_logger'} = $logger;
	}
	return $self->{'_logger'};
}

# sends an e-mail
# Parameters:
# self
# to_ref: reference to an array of correct e-mail names
# subject
# body
# false: error
# true: success

sub send_simple_email{
}

1;
