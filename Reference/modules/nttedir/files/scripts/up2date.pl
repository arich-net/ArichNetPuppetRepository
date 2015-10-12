#!/usr/bin/perl
#
# script to scan for package updates and mail out results if necessary
#
use strict;
use warnings;
use IO::Socket;
use Mail::Send;

sub test_network() {
  my $n=0;
  my $remote = IO::Socket::INET->new(  Proto    => 'tcp',
                                       PeerAddr  => 'man0.eu.verio.net',
                                       PeerPort  => '25',
                                       Timeout => '4',
                                    );

  unless ( $remote ) { die "Cannot connect to mail server!\n"; }

  $remote->autoflush(1);
  print $remote 'helo';
  print $remote 'quit';
  close $remote;
}

sub run_apt() {
  my @apt_list;

  # update package lists
  system ("apt-get update > /dev/null");

  # now simulate an upgrade and save output
  open APT, "apt-get --simulate dist-upgrade |" or die "apt tool is not functioning correctly: $!";
  while (<APT>) {
    if (/^Inst[\s\S]*$/) {
      my @split = split(' ', $_);
      my $next = "Package: $split[1]\nNew version available: $split[2] $split[3]\n\n";
      push @apt_list, $next 
    }
# NX-11457013
#    if (/0[\s\S]+upgraded[\s\S]+0[\s\S]+installed[\s\S]+0[\s\S]+remove[\s\S]+0[\s\S]+upgraded/) {
#      exit 0;
#    }
  }
  close APT;
  return (@apt_list);
}

sub send_mail(@) {
  my (@APT) = @_;
  chomp (my $hostname = `hostname`);
  my $to_addr = $hostname . "\@eu.verio.net";
  my $from_addr = "";

  # setup country support from address
  if ($hostname =~ /eul00/) {
    $from_addr = "dedicated_support\@verio.co.uk";
  } elsif ($hostname =~ /eul03/) {
    $from_addr = "dedicated_support\@verio.de";
  } elsif ($hostname =~ /eul06/) {
    $from_addr = "dedicated_support\@verio.es";
  } elsif ($hostname =~ /eul08/) {
    $from_addr = "dedicated_support\@verio.fr";
  } else {
    $from_addr = "dedicated_support\@verio.co.uk";
  }

  # Setup text-based header and signature strings
  my $HEADER = "Dear Valued Customer,\n\nYour server is using NTT Europe's Package Version and Patch Tracking Service to ensure that your operating system is up-to-date.\n\nThis email message contains important information pertaining to the status of your server's operating system and selected applications. Please read the output below carefully and refer to the related documentation online:\n\n";
  my $SIG = "\n\nIf you have any questions about this service, please do not hesitate to contact your support agent via the customer portal.\n\nBest regards,\n\nNTT Europe\nCustomer Operations";

  my $MAIL = new Mail::Send;
  $MAIL->to("$to_addr");
  $MAIL->set('From', "$from_addr");
  $MAIL->subject("System status report for $hostname.eu.verio.net");

  my $FH = $MAIL->open;
  print $FH $HEADER;
  print $FH @APT;
  print $FH $SIG;
  $FH->close;

}

sub main() {

  test_network();

  my @apt = run_apt();
  if (@apt >= 1) { send_mail(@apt); }

}

main();

exit 0;