#!/usr/bin/perl
#

package NTTEU::USF::Updates;

use strict;
use warnings;
use NTTEU::USF::Logger;

our $VERSION='0.5';

# Creates an instance of the update tool class
# Args
# 0: Class name (a convention in perl)
# 1: args reference to hash with
#  NTTEU.USF.Updates.logger = reference to a logger
sub new {
	my ($class,$logger) = @_;
	my $self = {};
	$self->{'_logger'} = $logger;
	bless($self,$class);
	$logger->debug("Update checker base class NTTEU::USF::Updates created ") if $logger;
	return($self);
}


# re-sets / gets the logger
#
sub logger {
	my ($self,$logger) = @_;
	if (defined $logger) {
		$self->{'_logger'} = $logger;
	}
	return $self->{'_logger'};
}

# Gets the list of available updates as an array reference two positions long.
# 0: list of updates as a reference to an array
# 1: list of dependencias as reference to an array or null. 
# If there are no updates returns [ [], [] ]
# If errors, returns false (0) and logs through the logger
# Arguments:
# None
sub get_available_updates {
	my ($self) = @_;
	$self->error("Not implemented yet!!!");
	return 0;
}
1;
