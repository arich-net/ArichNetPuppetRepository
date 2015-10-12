#!/usr/bin/perl

package NTTEU::USF::Config;

#####################################################
# Package for handling of configuration files       #
# v0.1 2009-08-14 cristobal.garcia@ntt.eu           #
#                                                   # 
#                                                   #
#            Config file format                     #
# key=value                                         #
# Comments with #                                   #
# whitelines allowed                                #
#####################################################

our $VERSION='0.5';

use NTTEU::USF::Logger;

# load_config
# Loads a config file and puts all the keys into a hash
# usage
#   NTTEU::USF::Config::load_config("filename",\%hash_referencei [,$logger_reference])
#   returns 1: good
#           0: bad
# 

sub load_config {
	($filename,$config_ref,$logger) = @_;
	my $res = 0;

	$filename = "" if(!$filename);
	$logger -> debug("Loading config file: $filename") if($logger);

	open(CONF,'<',$filename) or return 0;
	$logger -> debug("Configuration file opened") if($logger);
	while(my $line = <CONF>){
		chomp($line);
		$line =~ s/#.*$//;
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		$line =~ s/\s*=\s*/=/;
		if ($line =~ /^$/){
			next;
		}
		if (($line !~ /\S=\S/)&&($line !~ /\S=$/)){
			$logger -> error("Strange line after processing: $line") if($logger);
			next;
		}
		my ($key,$value) = split(/=/,$line);
		$config_ref -> {$key} = $value;
		$logger -> debug("configuration entry: $key->$value") if($logger);
	}
	close(CONF);
	$logger -> debug("Configuration file closed") if($logger);

	$res = 1;
	
	
}

	
1;
