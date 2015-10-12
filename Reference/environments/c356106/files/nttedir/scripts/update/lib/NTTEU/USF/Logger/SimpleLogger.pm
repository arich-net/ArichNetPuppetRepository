package NTTEU::USF::Logger::SimpleLogger;


#####################################################
# Package for handling logging.                     #
# subclass of NTTEU::USF::Logger                         #
# logs to the stderr                                #
#                                                   #
# v0.1 2009-08-14 cristobal.garcia@ntt.eu           #
#####################################################

# Usage:
# $logger = new NTTEU::USF::SimpleLogger();
# $logger -> loglevel(NTTEU::USF::Logger::LOG_INFO);
# $logger -> error("Error");
# $logger -> warn("Warning");

use strict;
use warnings;
use NTTEU::USF::Logger;

our @ISA = qw(NTTEU::USF::Logger);

our $VERSION = '0.5';


sub new {
	my ($class) = @_;
	my $self = $class->SUPER::new();
	bless ($self,$class);
	return $self;
}
	
sub emit_log_line {
	my ($self,$level_str,$msg) = @_;
	my $line = $self->compose_log_line($level_str,$msg);
	print STDERR "$line\n";
}

1;
