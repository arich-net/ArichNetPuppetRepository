package NTTEU::USF::Logger::RollingFileLogger;


#####################################################
# Package for handling logging.                     #
# subclass of NTTEU::USF::Logger                    #
# logs to a file rotating it daily and keeping      # 
# as much revisions as we want                      #
#                                                   #
# v0.1 2009-11-29 cristobal.garcia@ntt.eu           #
#####################################################

# Usage:
# $args = {'NTTEO.USF.Logger.RollingFileLogger.filepattern'=>'/etc/NTTEO/log/mylog','NTTEO.USF.Logger.RollingFileLogger.days_to_keep'=>5};
# $logger = new NTTEU::USF::RollingFileLogger($filepattern,$args);
# $logger -> loglevel(NTTEU::USF::Logger::LOG_INFO);
# $logger -> error("Error");
# $logger -> warn("Warning");
# Warning: It is not thread safe
# Warning: no two different process should share the same log

use strict;
use warnings;
use NTTEU::USF::Logger;

our @ISA = qw(NTTEU::USF::Logger);
our $VERSION = '0.1';


sub _now2str {
	my ($self) = @_;
	my @now  = gmtime();
	my $year = $now[5] + 1900;
	my $month = $now[4] + 1;
	my $day = $now[3];
	my $datestr = sprintf("%04d%02d%02d",$year,$month,$day);
	if ($self->debug_roll){
		my ($hour,$min,$sec) = reverse @now[0..2];
		$datestr .= sprintf("%02d%02d%02d",$hour,$min,$sec);
	}

	return $datestr;
}

sub _gmdate2str{
	my ($self,$date) = @_;
	my @date = gmtime($date);
	my $year = $date[5] + 1900;
	my $month = $date[4] + 1;
	my $day = $date[3];
	my $datestr = sprintf("%04d%02d%02d",$year,$month,$day);
	return $datestr;
}

sub _getdir($){
	my ($self,$file) = @_;

	my $dir = $file;
	$file =~ s/[^\/]+$//;
	if ($file eq ""){
		$file=".";
	}

	return $file;
}

sub _purge_files {
	my ($self) = @_;
	my $filepattern = $self->filepattern();
	my $days_to_keep = $self->days_to_keep();
	opendir(DIR,$self->_getdir($self->filepattern));
	my @files;
	if (!$self->debug_roll){
		@files = grep(/^\Q$filepattern\E\.\d{8}\.log$/,readdir(DIR)); 
	}else{
		@files = grep(/^\Q$filepattern\E\.\d{14}\.log$/,readdir(DIR)); 
	}
	my @files_sorted = reverse(sort(@files));
	while (scalar(@files_sorted) > $days_to_keep){
		my $file = pop(@files_sorted);
		unlink($file);
	}
	closedir(DIR);
}
	

sub new {
	my ($class,$filepattern,$days_to_keep,$debug_roll) = @_;
	my $self = $class->SUPER::new();
	bless ($self,$class);
	$self->{'_filepattern'} = $filepattern;
	$self->{'_days_to_keep'} = $days_to_keep;
	$self->{'_debug_roll'} = $debug_roll if $debug_roll;
	return 0 if $self->{'_days_to_keep'} <= 0;
	my $openfile_res = $self->open_log_file();
	return 0 if !$openfile_res;
	return $self;
}

sub open_log_file {
	my ($self) = @_;
	$self->{'_currentfilepath'} = $self->filepath_now();
	my $fh;
	my $open_res = open($fh,'>>',$self->{'_currentfilepath'}) or return 0;
	my $oldh = select($fh);
	$| = 1;
	select($oldh);
	$self->{'_filehandle'} = $fh;
	$self->_purge_files();
	return 1;
}
	

sub filepattern {
	my ($self,$fp) = @_;
	if ($fp){
		$self->{'_filepattern'}=$fp;
	}
	return $self->{'_filepattern'};
}

sub currentfilepath {
	my ($self,$cfp) = @_;
	if($cfp){
		$self->{'_currentfilepath'} = $cfp;
	}
	return $self->{'_currentfilepath'};
}

sub filepath_now {
	my ($self) = @_;
	return $self->{'_filepattern'}.".".$self->_now2str().".log";
}

sub days_to_keep {
	my ($self,$days) = @_;
	if ($days && ($days>0)){
		$self->{'_days_to_keep'} = $days;
	}
	return $self->{'_days_to_keep'};
}

sub debug_roll {
	my ($self) = @_;
	return $self->{'_debug_roll'};
}

sub filehandle($;$){
	my ($self,$fh) = @_;
	if ($fh){
		$self->{'_filehandle'} = $fh;
	}
	return $self->{'_filehandle'};
}
	
	
sub emit_log_line {
	my ($self,$level_str,$msg) = @_;
	my $line = $self->compose_log_line($level_str,$msg);
	if ($self->currentfilepath ne $self->filepath_now()){
		close($self->filehandle);
		$self->open_log_file;
		$self->_purge_files;
	}
	print {$self->filehandle} "$line\n";
}

sub DESTROY {
	my ($self) = @_;
	close($self->filehandle) if ($self->filehandle);
}
1;
