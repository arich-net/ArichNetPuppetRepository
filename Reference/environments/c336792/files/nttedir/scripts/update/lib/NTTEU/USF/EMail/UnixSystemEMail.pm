package NTTEU::USF::EMail::UnixSystemEMail;

use strict;
use warnings;
use NTTEU::USF::EMail;
use NTTEU::USF::Logger;
use NTTEU::USF::Exec;

our @ISA=qw(NTTEU::USF::EMail);

our $VERSION='0.1';

sub new {
	my ($class,$mail_bin,$mktemp_bin,$logger) = @_;
	my $self = $class->SUPER::new($logger);
	$self->{'_mail_bin'} = $mail_bin;
	$self->{'_mktemp_bin'} = $mktemp_bin;
	return $self;
}

sub mail_bin {
	my ($self,$mail_bin) = @_;
	if (defined($mail_bin)){
		$self->{'_mail_bin'} = $mail_bin;
	}
	return $self->{'_mail_bin'};
} 

sub mktemp_bin {
	my ($self,$mail_bin) = @_;
	if (defined($mail_bin)){
		$self->{'_mktemp_bin'} = $mail_bin;
	}
	return $self->{'_mktemp_bin'};
} 

sub fill_temp_file{
	my ($self,$tmpfile_name,$body) = @_;
	my $logger = $self->logger();
	my $res = "";
	$logger->debug("Filling tmpfile");
	$logger->debug("Opening tmpfile:$tmpfile_name");
	if(!open(TMP,">",$tmpfile_name)){
		$logger->error("Could not write to $tmpfile_name");
		return 0;
	}
	$logger->debug("Tmpfile opened");
	print TMP $body;
	close(TMP);
	$logger->debug("Tmpfile closed");
	return 1;
}


sub send_simple_email{
	my ($self,$to_ref,$subject,$body,) = @_;
	my $res = 0;
	my $logger = $self->logger();

	$logger->debug("send_simple_email finished");
	my @mktemp_output = ();
	$logger->debug("Creating temporary file");
	my $cmd_mktemp = $self->mktemp_bin . " -t ntteo_send_simple_mail.XXXXXXXXXXXXXXXXXXXXXXXXXXX";
	my $mktemp_res = NTTEU::USF::Exec::shell_exec_command($cmd_mktemp,$logger,\@mktemp_output);
	if($mktemp_res){
		$logger->error("Error creating tmp file");
		return 0;
	}
	my $tempfile_name = $mktemp_output[0];
	my $fill_res = $self->fill_temp_file($tempfile_name,$body);
	if (!$fill_res){
		$logger->error("Error filling temp file");
		return 0;
	}
	$logger->debug("Sending e-mail");
	my $cmd_to = join(',',@$to_ref);
	my $cmd_subject = "-s '".$subject."'";
	my $cmd_email = $self->mail_bin . " $cmd_subject $cmd_to";
	$cmd_email = "$cmd_email < $tempfile_name";
	my $mail_res = NTTEU::USF::Exec::shell_exec_command($cmd_email,$logger);
	if ($mail_res){
		$logger->error("Some error has happend sending the e-mail");
		$res = 0;
	}else{
		$res = 1;
	}
	$logger->debug("Unlinking tmp file $tempfile_name");
	my $unlink_res = unlink(($tempfile_name));
	if (!$unlink_res){
		$logger->error("Error removing $tempfile_name");
	}else{
		$logger->debug("Tempfile removed correctly");
	}
	$logger->debug("send_simple_email finished");
	return $res;
}

1;
