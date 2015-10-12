package NTTEU::USF::Logger;

#####################################################
# Package for handling logging. It is the equivalent#
# of an abstract class or interface                 #
# the real job is done by classes inheriting from   #
# this one                                          #
# v0.1 2009-08-14 cristobal.garcia@ntt.eu           #
#                                                   #
# Inspired in log4j/log4perl but does not           #
# need external libraries. It is installed only     #
# by copying it.                                    #
#####################################################

# Usage:
# $logger = new NTTEU::USF::<Real Logger Class, for instance: SimpleLogger>
# $logger -> loglevel(NTTEU::USF::Logger::LOGLEVEL_DEBUG) 
# $logger -> error("txt") logs a message with LOG_ERROR severity
# $logger -> warn("txt") logs a messge with LOG_WARN severity
# $logger -> info("txt) logs a mesage with LOG_INFO severity
# $logger -> debug("txt") logs a message with LOG_DEBUG severity
# loglevels are ordered this way
# LOG_NONE < LOG_ERROR < LOG_WARN < LOG_INFO < LOG_DEBUG
# when the loglevel is set to a level, only messages of this severity or 
# lower, will be logged. 
# For instance, NOTHING WILL BE LOGGED IN THE FOLLOWING CODE
#  $logger->loglevel(NTTEU::USF::Logger::LOGLEVEL_ERROR);
#  $logger->debug("An error!!!");
# 
# Here, the error it will be logged
#  $logger->loglevel(NTTEU::USF::Logger::LOGLEVEL_INFO);
#  $logger->warn("A warning!!!");


our $VERSION='0.5';

use strict;
use warnings;

use constant {
	LOG_NONE_IDX => 0,
	LOG_ERROR_IDX => 1,
	LOG_WARN_IDX => 2,
	LOG_INFO_IDX => 3,
	LOG_DEBUG_IDX => 4
	};

use constant {
	DEFAULT_LOCALE => "en_US"
	};


my $LOG_LEVELS =  {
	&LOG_NONE_IDX => 0,
	&LOG_ERROR_IDX => 1,
	&LOG_WARN_IDX => 2,
	&LOG_INFO_IDX => 3,
	&LOG_DEBUG_IDX => 4
	};

my $LOG_LEVELS_STR = {
	&LOG_NONE_IDX => "NONE",
	&LOG_ERROR_IDX => "ERROR",
	&LOG_WARN_IDX => "WARN",
	&LOG_INFO_IDX => "INFO",
	&LOG_DEBUG_IDX => "DEBUG"
	};

sub Loglevel_data {
	my $res;
	my ($level_i,$locale) = @_;
	if (defined($locale)){
		$res = $LOG_LEVELS_STR->{"$level_i"};
	} else {
		$res = $LOG_LEVELS->{"$level_i"};
	}
	return $res;
}

sub LOG_NONE {
	my ($locale) = @_;
	return Loglevel_data(LOG_NONE_IDX,$locale);
}

sub LOG_ERROR {
	my ($locale) = @_;
	return Loglevel_data(LOG_ERROR_IDX,$locale);
}

sub LOG_WARN {
	my ($locale) = @_;
	return Loglevel_data(LOG_WARN_IDX,$locale);
}

sub LOG_INFO {
	my ($locale) = @_;
	return Loglevel_data(LOG_INFO_IDX,$locale);
}

sub LOG_DEBUG {
	my ($locale) = @_;
	return Loglevel_data(LOG_DEBUG_IDX,$locale);
}

sub new {
	my ($class) = @_;
	my $self = {};
	bless($self,$class);
	$self->loglevel(NTTEU::USF::Logger::LOG_ERROR);
	return $self;
}

sub loglevel {
	my ($self,$level) = @_;
	if(defined($level)) {
		$self->{"_loglevel"} = $level;
	}
	return $self->{"_loglevel"};
}

sub loglevel_str {
	my ($self,$locale) = @_;

	$locale = DEFAULT_LOCALE if (!$locale);

	my $level = $self->{"_loglevel"};
	my $res = "";
	if ($level == NTTEU::USF::Logger::LOG_NONE){
		$res = NTTEU::USF::Logger::LOG_NONE($locale);
	}elsif ($level == NTTEU::USF::Logger::LOG_ERROR) {
		$res = NTTEU::USF::Logger::LOG_ERROR($locale);
	}elsif ($level == NTTEU::USF::Logger::LOG_WARN) {
		$res = NTTEU::USF::Logger::LOG_WARN($locale);
	}elsif ($level == NTTEU::USF::Logger::LOG_INFO) {
		$res = NTTEU::USF::Logger::LOG_INFO($locale);
	}elsif ($level == NTTEU::USF::Logger::LOG_DEBUG) {
		$res = NTTEU::USF::Logger::LOG_DEBUG($locale);
	}else{
		$res = "";
	}
	return $res;
}
	



sub compose_log_line {
	my ($self,$loglevelstr,$msg) = @_;
	my ($sec,$min,$hour,$mday,$mon,$year) = gmtime();	
	my $nmon = $mon +1;
	my $nyear = $year + 1900;
	my $res = sprintf("%04d-%02d-%02d %02d:%02d:%02d [%s] %s",$nyear,$nmon,$mday,$hour,$min,$sec,$loglevelstr,$msg);
	return $res;
}

sub emit_log_line {
}

sub error {
	my ($self,$message,$locale) = @_;
	$locale = DEFAULT_LOCALE if (!$locale);
	if ($self->loglevel >= NTTEU::USF::Logger::LOG_ERROR) { 
		$self->emit_log_line(NTTEU::USF::Logger::LOG_ERROR($locale),$message);
	}
}

sub warn {
	my ($self,$message,$locale) = @_;
	$locale = DEFAULT_LOCALE if (!$locale);
	if ($self->loglevel >= NTTEU::USF::Logger::LOG_WARN) { 
		$self->emit_log_line(NTTEU::USF::Logger::LOG_WARN($locale),$message);
	}
}
	
sub info {
	my ($self,$message,$locale) = @_;
	$locale = DEFAULT_LOCALE if (!$locale);
	if ($self->loglevel >= NTTEU::USF::Logger::LOG_INFO) { 
		$self->emit_log_line(NTTEU::USF::Logger::LOG_INFO($locale),$message);
	}
}

sub debug {
	my ($self,$message,$locale) = @_;
	$locale = DEFAULT_LOCALE if (!$locale);
	if ($self->loglevel >= NTTEU::USF::Logger::LOG_DEBUG) { 
		$self->emit_log_line(NTTEU::USF::Logger::LOG_DEBUG($locale),$message);
	}
}

1;
