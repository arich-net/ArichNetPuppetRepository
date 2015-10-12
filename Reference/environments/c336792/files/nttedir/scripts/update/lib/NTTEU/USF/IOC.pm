package NTTEU::USF::IOC;

use strict;
use warnings;

our $VERSION='0.1';

use NTTEU::USF::Logger;
use NTTEU::USF::Logger::SimpleLogger;
use NTTEU::USF::Config;
use NTTEU::USF::DynaLoader;

# configuration sample
# ioc.services = svc1,svc2
# ioc.logger.class
# ioc.logger.argc
# ioc.logger.argv.1
# svc1.class=NTTEO::USF:Logger::RollingFileLogger;
# svc1.argc=1
# svc1.argv.1="/etc/NTTEO/logs/log1.log"
# svc2.class=NTTEO::USF::Email::UnixSystemEmail;
# svc2.argc=1
# svc2.argv=$svc{svc1}

sub _create_object{
	my ($self,$prefix) = @_;
	my $logger = $self->logger;
	my $config = $self->config;
	$logger -> debug("Creating object in $prefix");

	my $class = $config->{"$prefix.class"};
	if (!$class){
		$logger->error("$prefix.class should be in the configuration file and it is not");
		return 0;
	}
	$logger -> debug("Class: $class");
	my $argc = $config->{"$prefix.argc"};
	if ((!$argc)||($argc !~ /\d+/)){
		$logger->error("$prefix.argc should be present in the configuration file and it is not or it is not an integer");
		return 0;
	}
	$logger -> debug("Argc: $argc");
	my @argv = ();
	for (my $i=1;$i<=$argc;$i++){
		my $aux = $config->{"$prefix.argv.$i"};
		if (!$aux){
			$logger->error("$prefix.argv.$i should be present in the ioc config file and it is not");
			next;
		}
		$logger->debug("Arg $i:$aux");
		if ($aux =~ /^\$svc\{([^\}]+)\}/){

			my $svc = $self->service_by_name($1);
			$logger->debug("Service parameter pointing to $svc");

			if(!$svc){
				$logger->error("Service $svc has not been created in the services database yet");
			}else{
				$logger->debug("Service $svc found. Adding to the parameter list");
				push(@argv,$self->service_by_name($1));
			}
		}else{
			$logger->debug("Scalar parameter. Adding it to the list");
			push(@argv,$aux);
		}	
	}
	my $res = NTTEU::USF::DynaLoader::create_dyn_object($class,$self->logger,@argv);
	if($res){
		$logger->debug("Dynamic object created with result: $res");
	}else{
		$logger->debug("Dynamic object not created correctly");
	}
	return $res;
}

sub _parse_config{
	my ($self) = @_;
	my $logger = $self->logger;
	$logger->debug("Analyzing configuration");
	if($self->config->{"ioc.logger.class"}){
		$logger->debug("Changing logger as requested");
		my $new_logger = $self->_create_object("ioc.logger");
		$logger->debug("Logger successfully created");
		if($new_logger){
			$self->logger($new_logger);
			$logger->debug("Welcome to the new logger");
		}else{
			$logger->error("Error creating the new logger. Keeping the default one");
		}
	}
	my @svcs = split(/\s*,\s*/,$self->config->{"ioc.services"});
	foreach my $svc_name (@svcs){
		$logger->debug("Adding service: $svc_name");
		my $svc_ref = $self->_create_object("$svc_name");
		if($svc_ref){
			$logger->debug("$svc_name service created sucessfully");
			$self->add_service($svc_name,$svc_ref);
		}else{
			$logger->error("$svc_name was not created.");
		}
	}
}


sub new {
	my ($class,$conf_file,$logger) = @_;
	my $self = {};
	bless($self,$class);


	my $conf = {};
	if (!$logger){
		$self->{'_logger'} = new NTTEU::USF::Logger::SimpleLogger();
	}else{
		$self->{'_logger'} = $logger;
	}
	$logger = $self->{'_logger'};
	$logger->debug("Creating IOC object");
	my $conf_res = NTTEU::USF::Config::load_config($conf_file,$conf,$self->{'_logger'});
	if (!$conf_res){
		$logger->error("Error reading config file");
		return 0
	}
	$self->{'_config'} = $conf;
	$self->_parse_config;
	return $self;
}

sub logger{
	my ($self,$logger) = @_;
	if ($logger){
		$self->{'_logger'} = $logger;
	}
	return $self->{'_logger'};
}

sub service_by_name {
	my ($self,$svc) = @_;
	return $self->{"_services"}->{"$svc"};
}

sub services {
	my ($self) = @_;
	return $self->{"_services"};
}

sub add_service {
	my ($self,$svc_name,$svc_ref) = @_;
	$self->{'_services'}->{"$svc_name"} = $svc_ref;
}

sub config {
	my ($self) = @_;
	return $self->{'_config'};
}
1;
