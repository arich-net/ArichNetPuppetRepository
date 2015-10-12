#!/usr/bin/perl

use strict;
use warnings;
require 5.008;

use NTTEU::USF::Logger;
use NTTEU::USF::Logger::SimpleLogger;
use NTTEU::USF::EMail;
use NTTEU::USF::Config;
use NTTEU::USF::IOC;
use NTTEU::USF::Exec;
use Getopt::Long;



sub check_config{
	my ($config,$logger) = @_;

	$logger->debug("Checking configuration file");
	if (!defined $config->{'to'}){
		$logger->error("to option is not present in the config file");
		return 0;
	}
	$logger->debug("Configuration file was correct");
	return 1;
}


# generates the e-mail body 
# the updates list needs not to be empty
# the deps list can be empty
sub generate_body{
	my ($updates) = @_;
	my $upd_list = $updates -> [0];
	my $dep_list = $updates -> [1];

	if (!$dep_list){
		$dep_list = [];
	}
	
	my $res = <<EOF;
Dear Sirs,

The following updates are available for this system:

EOF
	foreach my $upd_item (@$upd_list) {
		$res .= "\t * $upd_item\n";
	}

	if (scalar @$dep_list > 0){
		$res .= <<EOF;

Also, the following packages are listed as dependencies:

EOF
		foreach my $dep_item (@$dep_list){
			$res .= "\t * $dep_item\n";
		}
	}

	$res .= <<EOF;

Kindest regards

NTTEO Central Engineering

EOF
	return $res;
}

sub get_hostname {
	my ($logger) = @_;
	my @paths = ('/bin','/usr/bin','/sbin','/usr/sbin');
	my $found = 0;
	my $cmd = 0;
	
	for(my $i=0;$i<=$#paths;$i++){
		my $path = $paths[$i];
		if (-x "$path/hostname" ){
			$cmd = "$path/hostname";
			last;
		}
	}

	if (!$cmd){
		$logger->error("Could not find hostname");
		return 0;
	}
	
	my @output;
	my $cmd_res = NTTEU::USF::Exec::shell_exec_command($cmd,$logger,\@output);
		
	if ($cmd_res !=0 ){
		$logger->error("Error executing command. Returned status = $cmd_res");
		return 0;
	}
	my $res = $output[0];

	return $res;
}
	
my $options = {};
my $config = {};
my $ioc;
my $basic_logger;
my $logger_svc;
my $email_svc;
my $update_svc;

$basic_logger = new NTTEU::USF::Logger::SimpleLogger();

GetOptions($options,'ioc=s','debug','config=s');

$basic_logger -> loglevel(NTTEU::USF::Logger::LOG_DEBUG) if $options->{'debug'};

if ((!$options -> {'ioc'})||(! -f $options -> {'ioc'})){
	$basic_logger->error("ioc cli option not set or file not found");
	exit(1);
}

if ((!$options -> {'config'})||(! -f $options ->{'config'})){
	$basic_logger->error("config cli option not set or file not found");
	exit(1);
}

$basic_logger->debug("Reading IOC config file");
$ioc = new NTTEU::USF::IOC($options->{'ioc'},$basic_logger);

if(!$ioc){
	$basic_logger->error("IOC Container not loaded");
	exit(1);
}
$logger_svc = $ioc->service_by_name("logger");

if ($options->{'debug'}){
	$logger_svc->loglevel(NTTEU::USF::Logger::LOG_DEBUG);
}else{
	$logger_svc->loglevel(NTTEU::USF::Logger::LOG_INFO);
}

$email_svc = $ioc->service_by_name("email");
$update_svc = $ioc->service_by_name("updates");

#Change the IOC logger to the one defined in the config
$ioc->logger($logger_svc);

$logger_svc->info("Starting update check");

my $config_res = NTTEU::USF::Config::load_config($options->{'config'},$config,$logger_svc);

if (!$config_res){
	$logger_svc -> error("Problems reading the config file");
	exit(1);
}

if (!check_config($config,$logger_svc)){
	$logger_svc -> error("Config file was not correct");
	exit(1);
}

my $updates = $update_svc->get_available_updates();

if ((!$updates)||(!defined($updates->[0]))){
	$logger_svc->error("Update list is null");
	exit(1);
}

my $update_list = $updates->[0];
my $dep_list = $updates->[1];

if (scalar @$update_list > 0){
	$logger_svc -> info("Updates found. An e-mail needs to be sent");
}else{
	$logger_svc -> info("No updates found. Exiting");
	exit(0);
}

my $body = generate_body($updates);
my $hostname = get_hostname($logger_svc);
my $subject = "Patching report for $hostname";

my @to = split(/\s*,\s*/,$config->{'to'});
my $email_res = $email_svc -> send_simple_email(\@to,$subject,$body);

if ($email_res){
	$logger_svc -> debug("Message sucessfully sent");
}else{
	$logger_svc -> error("Error sending message");
	exit(1);
}

$logger_svc->info("Finished update check");
