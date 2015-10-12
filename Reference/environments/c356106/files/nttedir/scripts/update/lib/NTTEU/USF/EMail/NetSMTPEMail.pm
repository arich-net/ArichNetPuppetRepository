package NTTEU::USF::EMail::NetSMTPEMail;

use strict;
use warnings;

use NTTEU::USF::Logger;
use NTTEU::USF::EMail;
use NTTEU::USF::Exec;
use Net::SMTP;

our @ISA = qw(NTTEU::USF::EMail);
use constant HOSTNAME_PATH=>qw( /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin);

our $VERSION='0.1';

sub _gethostname {
	my ($self) = @_;
	my $logger = $self->logger;
	$logger->debug("Getting the hostname");
	$logger->debug("Searching for the hostname binary");

	my $hostname_bin = 0;
	for my $dir (&HOSTNAME_PATH){
		my $bin = "$dir/hostname";
		if (-x $bin){
			$hostname_bin = $bin;
			last;
		}
	}
	if ($hostname_bin) {
		$logger->debug("Hostname tool found in:$hostname_bin");
	} else {
		$logger->error("Hostname tool not found");
		return 0;
	}

	my $hostname_output = [];
	my $hostname_bin_res = NTTEU::USF::Exec::shell_exec_command($hostname_bin,$logger,$hostname_output);
	if ($hostname_bin_res != 0){
		$logger->error("Error executing comadn $hostname_bin");
		return 0;
	}
	my $hostname = $hostname_output->[0];
	chomp($hostname);
	return $hostname;
}

sub new {
	my ($class,$relay,$logger) = @_;
	my $self = $class->SUPER::new($logger);
	$self->{'_relay'} = $relay;
	return $self;
}

sub relay {
	my ($self) = @_;

	return $self->{'_relay'};
}

sub send_simple_email {
	my ($self,$to_ref,$subject,$body) = @_;

	my $logger = $self->logger;
	my $login = getlogin || getpwuid($<) || "unknown";
	my $from = $login."@".$self->_gethostname();

	$logger->debug("Contacting with the e-mail relay");
	my $smtp = new Net::SMTP($self->relay);
	if(!$smtp){
		$logger->error("Problems contacting with ".$self->relay);
		return 0;
	}
	$logger->debug("Contact succeeded. Now preparing e-mail");
	if (!$smtp -> mail($from)){
		$logger->error("Error preparing e-mail from:$from");
		return 0;
	}
	if (!$smtp -> recipient(@$to_ref)){
		$logger->error("Error preparig e-mail recipients");
		return 0;
	}

	$logger->debug("Message prepared");
	my $msg = "MIME-Version: 1.0\n".
		"From: $from\n".
		"To: ".join(";",@$to_ref)."\n".
		"Subject: $subject\n".
		"\n\n".
		$body;

	if (!$smtp -> data($msg)){
		$logger->error("Problems sending message");
		return 0;
	}
	$logger->debug("Message sent");
	$smtp->quit;
	return 1;
}
1;
