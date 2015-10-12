#!/bin/perl
# CIS checks Perl Script
#
# Check if there is arguments
# Version 1 Ariel Vasquez
use Config::Simple;
use Log::Log4perl;

if ($#ARGV eq -1) {
	print("Usage: Check_CIS.pm generate|check|showdiff LoggerConfPath ConfigPath\n");
	system.exit();
}

# print ("VAR: " . $1 . " VAR2: " . $ARGV[0] . "\n");

# Initialize the logger
if ($ARGV[1] eq "") {
        Log::Log4perl::init('pci_logger.cfg') or die $logger->error("PCI Logger Confguration file not Found");
}
else {  
        Log::Log4perl::init($ARGV[1]) or die $logger->error("PCI Logger Confguration file not Found");
}
$logger = Log::Log4perl->get_logger('log4perl.rootLogger');
$logger->debug("Logger initialized");

# Config file manager
if ($ARGV[2] eq "") {
        $cfg = new Config::Simple('pci_config.cfg') or die $logger->error("PCI Confguration file not Found");
}
else {  
        $cfg = new Config::Simple($ARGV[2]) or die $logger->error("PCI Confguration file not Found");
}


# Get fstab entries
$fstab = '/etc/fstab';
@path_array = `grep -v '^#' $fstab | awk '(\$6 != "0") { print \$2 }'`;

# Get the user that executes the script
$user = `who am i | awk '{print \$1}'`;

if ($ARGV[0] eq "generate") {
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# +  Requirement 7.5 Check World-Writable Directories without the sticky bit +
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	$logger->info("*** Generating templates and MD5 ***");
	# Generate the list of the requirement 7.5 of CIS Hardening Standard
	$logger->info("REQ 7.5 -> Find World Writtable Directories without the Sticky Bit Set");
	$req75_template = $cfg->param('75_cis_ww_dirs_template');

	# Remove Req75 Template	
	system("rm -rf " . $req75_template);
	$logger->debug("Command executed = rm -rf " . $req75_template);
	
	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;
		system("find " . $path . " -ignore_readdir_race -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\) >> " . $req75_template);
		$logger->debug("Command executed = find " . $path . " -ignore_readdir_race -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\) >> " . $req75_template);	
	}

	# Take the MD5 result
	$md5_75req = `cat $req75_template | md5sum | awk '{print \$1}'`;
	$logger->debug("Command executed = cat $req75_template | md5sum | awk '{print \$1}'");
	chomp $md5_75req;
	$logger->debug("Req. 7.5 MD5= " . $md5_75req );
	$logger->info("Saving value " . $md5_75req . " on parameter md5_req75");
	$cfg->param('75_cis_ww_dirs_md5', $md5_75req);
	$cfg->save() or die $logger->error("Not possible to save generated configuration");

	$logger->info("MD5 Requirement 7.5 saved by " . $user);


	# ++++++++++++++++++++++++++++++++++++++++++++++++
	# +  Requirement 7.6 Check World-Writable Files  +
	# ++++++++++++++++++++++++++++++++++++++++++++++++
	$logger->info("REQ 7.6 -> Find Unauthorized World-Writable Files");
	$req76_template = $cfg->param('76_cis_ww_files_template');

	# Remove Req76 Template	
	system("rm -rf " . $req76_template);
	$logger->debug("Command executed = rm -rf " . $req76_template);

	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;
		system("find $path -ignore_readdir_race -xdev -type f \\( -perm -0002 -a ! -perm -1000 \\) >> " . $req76_template);
		$logger->debug("Command executed = find $path -ignore_readdir_race -xdev -type f \\( -perm -0002 -a ! -perm -1000 \\) >> " . $req76_template);
	}

	# Take the MD5 result
        $md5_76req = `cat $req76_template | md5sum | awk '{print \$1}'`;
	$logger->debug("Command executed: cat $req76_template | md5sum | awk '{print \$1}");
	chomp $md5_76req;
	$logger->debug("Req. 7.6 MD5= " . $md5_76req );
        $logger->info("Saving value " . $md5_76req . " on parameter md5_req76");
	$cfg->param('76_cis_ww_files_md5', $md5_76req);
        $cfg->save() or die $logger->error("Not possible to save generated configuration");
	$logger->info("MD5 Requirement 7.6 saved by " . $user);


	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  	# +  Requirement 7.7 Find Unauthorized SUID/SGID System Executables  +
  	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	$logger->info("REQ 7.7 -> Find Unauthorized SUID/SGID System Executables");
	$req77_template = $cfg->param('77_cis_rogue_suid_template');

	# Remove Req77 Template	
	system("rm -rf " . $req77_template);
	$logger->debug("Command executed = rm -rf " . $req77_template);

	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;
		system("find $path -ignore_readdir_race -xdev -type f \\( -perm -04000 -o -perm -02000 \\) >> " . $req77_template);
		$logger->debug("Command executed = find $path -ignore_readdir_race -xdev -type f \\( -perm -04000 -o -perm -02000 \\) >> " . $req77_template);
	}

	# Take the MD5 result
        $md5_77req = `cat $req77_template | md5sum | awk '{print \$1}'`;
	$logger->debug("Command executed: cat $req77_template | md5sum | awk '{print \$1}");
	chomp $md5_77req;
	$logger->debug("Req. 7.7 MD5= " . $md5_77req );
        $logger->info("Saving value " . $md5_77req . " on parameter md5_req77");
	$cfg->param('77_cis_rogue_suid_md5', $md5_77req);
        $cfg->save() or die $logger->error("Not possible to save generated configuration");
	$logger->info("MD5 Requirement 7.7 saved by " . $user);			


	# ++++++++++++++++++++++++++++++++++++++++++++
 	# +  Requirement 7.8 Find All Unowned Files  +
  	# ++++++++++++++++++++++++++++++++++++++++++++
	$logger->info("REQ 7.8 -> Find All Unowned Files");
	$req78_template = $cfg->param('78_cis_unowned_template');

	# Remove Req78 Template	
	system("rm -rf " . $req78_template);
	$logger->debug("Command executed = rm -rf " . $req78_template);

	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;
		system("find $path -ignore_readdir_race -xdev -type f -nouser -o -nogroup >> " . $req78_template);
		$logger->debug("Command executed = find $path -ignore_readdir_race -type f -xdev -nouser -o -nogroup >> " . $req78_template);
	}

	# Take the MD5 result
        $md5_78req = `cat $req78_template | md5sum | awk '{print \$1}'`;
	$logger->debug("Command executed: cat $req78_template | md5sum | awk '{print \$1}");
	chomp $md5_78req;
	$logger->debug("Req. 7.8 MD5= " . $md5_78req );
        $logger->info("Saving value " . $md5_78req . " on parameter md5_req78");
	$cfg->param('78_cis_unowned_md5', $md5_78req);
        $cfg->save() or die $logger->error("Not possible to save generated configuration");
	$logger->info("MD5 Requirement 7.8 saved by " . $user);			
}

elsif ($ARGV[0] eq "check") {
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# +  Requirement 7.5 Check World-Writable Directories without the sticky bit +
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	$logger->info("*** Checking CIS compliancy ***");
	$logger->info("Checking Requirement 7.5 World-Writtable Directories without the Sticky Bit Set");
	
	# Remove all CIS temporary files
	system("rm -rf /tmp/CIS*");
	$logger->debug("Command executed = rm -rf /tmp/CIS*");
	
	# Look for this info in path array
	foreach $path (@path_array) {
		chomp $path;	
		system("find " . $path . " -ignore_readdir_race -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\) >> /tmp/CIS_75.tmp");
		$logger->debug("Command executed = find " . $path . " -ignore_readdir_race -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\) >> /tmp/CIS_75.tmp");	
	}

	$md5_75req = `cat /tmp/CIS_75.tmp | md5sum | awk '{print \$1}'`;
	$logger->debug("Command executed = cat /tmp/CIS_75.tmp | md5sum | awk '{print \$1}'");
	chomp $md5_75req;
	$md5_75req_config = $cfg->param('75_cis_ww_dirs_md5');

	#Compare both results, they should match
	if ($md5_75req eq $md5_75req_config) {
		$logger->info("Requirement 7.5 Check World-Writtable Directories without the Sticky Bit Set OK");	
	}
	else {
		$logger->error("Requirement 7.5 Check World-Writtable Directories without the Sticky Bit Set NOK");
	}
	

	# ++++++++++++++++++++++++++++++++++++++++++++++++
	# +  Requirement 7.6 Check World-Writable Files  +
	# ++++++++++++++++++++++++++++++++++++++++++++++++
	$logger->info("Checking Requirement 7.6 World-Writtable Files");
	
	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;	
		system("find $path -ignore_readdir_race -xdev -type f \\( -perm -0002 -a ! -perm -1000 \\) >> /tmp/CIS_76.tmp");
		$logger->debug("Command executed = find $path -ignore_readdir_race -xdev -type f \\( -perm -0002 -a ! -perm -1000 \\) >> /tmp/CIS_76.tmp");
	}
	
	$md5_76req = `cat /tmp/CIS_76.tmp | md5sum | awk '{print \$1}'`;
        $logger->debug("Command executed: cat /tmp/CIS_76.tmp | md5sum | awk '{print \$1}'");
	chomp $md5_76req;
        $md5_76req_config = $cfg->param('76_cis_ww_files_md5');

	#Compare both results, they should match
        if ($md5_76req eq $md5_76req_config) {
                $logger->info("Requirement 7.6 Check World-Writtable Files OK");
        }
        else {
                $logger->error("Requirement 7.6 Check World-Writtable Files NOK");
        }

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	# +  Requirement 7.7 Find Unauthorized SUID/SGID System Executables  +
 	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	$logger->info("Checking Requirement 7.7 Find Unauthorized SUID/SGID System Executables");

	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;
		system("find $path -ignore_readdir_race -xdev -type f \\( -perm -04000 -o -perm -02000 \\) >> /tmp/CIS_77.tmp");
		$logger->debug("Command executed = find $path -ignore_readdir_race -xdev -type f \\( -perm -04000 -o -perm -02000 \\) >> /tmp/CIS_77.tmp");
	}
	
	$md5_77req = `cat /tmp/CIS_77.tmp | md5sum | awk '{print \$1}'`;
        $logger->debug("Command executed: cat /tmp/CIS_77.tmp | md5sum | awk '{print \$1}'");
	chomp $md5_77req;
        $md5_77req_config = $cfg->param('77_cis_rogue_suid_md5');

	#Compare both results, they should match
        if ($md5_77req eq $md5_77req_config) {
                $logger->info("Requirement 7.7 Find Unauthorized SUID/SGID System Executables OK");
        }
        else {
                $logger->error("Requirement 7.7 Find Unauthorized SUID/SGID System Executables NOK");
        }


	# ++++++++++++++++++++++++++++++++++++++++++++
	# +  Requirement 7.8 Find All Unowned Files  +
  	# ++++++++++++++++++++++++++++++++++++++++++++
	$logger->info("Checking Requirement 7.8 Find All Unowned Files");

	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;
		system("find $path -ignore_readdir_race -xdev -type f -nouser -o -nogroup >> /tmp/CIS_78.tmp");
		$logger->debug("Command executed = find $path -ignore_readdir_race -type f -xdev -nouser -o -nogroup >> /tmp/CIS_78.tmp");
	}

	
	$md5_78req = `cat /tmp/CIS_78.tmp | md5sum | awk '{print \$1}'`;
        $logger->debug("Command executed: cat /tmp/CIS_78.tmp | md5sum | awk '{print \$1}'");
	chomp $md5_78req;
        $md5_78req_config = $cfg->param('78_cis_unowned_md5');

	#Compare both results, they should match
        if ($md5_78req eq $md5_78req_config) {
                $logger->info("Requirement 7.8 Find All Unowned Files OK");
        }
        else {
                $logger->error("Requirement 7.8 Find All Unowned Files NOK");
	}

	# Remove temporary files
	system("rm -rf /tmp/CIS*");
}

elsif ($ARGV[0] eq "showdiff") {
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# +  Requirement 7.5 Check World-Writable Directories without the sticky bit +
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	$logger->info("*** Showing diff from templates ***");
	$logger->info("Executed by " . $user);
	
	# Remove all CIS temporary files
	system("rm -rf /tmp/CIS*");
	$logger->debug("Command executed = rm -rf /tmp/CIS*");
	
	# Look for this info in path array
	foreach $path (@path_array) {
		chomp $path;	
		system("find " . $path . " -ignore_readdir_race -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\) >> /tmp/CIS_75.tmp");
		$logger->debug("Command executed = find " . $path . " -ignore_readdir_race -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\) >> /tmp/CIS_75.tmp");	
	}
	
	# Comparing both results
	$req75_template = $cfg->param('75_cis_ww_dirs_template');
	$differences = `diff /tmp/CIS_75.tmp $req75_template`;
	chomp $differences;
	if ($differences ne "") {
		print ("Req. 7.5 Check World-Writable Directories -> Comparing Result(\<) vs Template(\>)\n");
		$logger->info("Command Executed: diff /tmp/CIS_75.tmp " . $req75_template);
		$logger->info("There are differences for Requirement 7.5");
		print $differences . "\n";
		$logger->debug("Req. 7.5 Check World-Writable Directories -> Comparing Result(\<) vs Template(\>)");
		$logger->debug($differences);
	}
	else {
		print ("Req. 7.5 Check World-Writable Directories - No differences between Template and Result\n");
		$logger->info("Req. 7.5 Check World-Writable Directories - No differences between Result and Template");
	}


	# ++++++++++++++++++++++++++++++++++++++++++++++++
	# +  Requirement 7.6 Check World-Writable Files  +
	# ++++++++++++++++++++++++++++++++++++++++++++++++
	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;	
		system("find $path -ignore_readdir_race -xdev -type f \\( -perm -0002 -a ! -perm -1000 \\) >> /tmp/CIS_76.tmp");
		$logger->debug("Command executed = find $path -ignore_readdir_race -xdev -type f \\( -perm -0002 -a ! -perm -1000 \\) >> /tmp/CIS_76.tmp");
	}
	
	# Comparing both results
        $req76_template = $cfg->param('76_cis_ww_files_template');
	$differences = `diff /tmp/CIS_76.tmp $req76_template`;
	chomp $differences;
	if ($differences ne "") {
                print ("Req. 7.6 Check World-Writable Files -> Comparing Result(\<) vs Template(\>)\n");
                $logger->info("Command Executed: diff /tmp/CIS_76.tmp " . $req76_template);
		$logger->info("There are differences for Requirement 7.6");
                print $differences . "\n";
                $logger->debug("Req. 7.6 Check World-Writable Files -> Comparing Result(\<) vs Template(\>)");
                $logger->debug($differences);
        }
        else {
                print ("Req. 7.6 Check World-Writable Files - No differences between Template and Result\n");
                $logger->info("Req. 7.6 Check World-Writable Files - No differences between Result and Template");
        }

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  	# +  Requirement 7.7 Find Unauthorized SUID/SGID System Executables  +
  	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;
		system("find $path -ignore_readdir_race -xdev -type f \\( -perm -04000 -o -perm -02000 \\) >> /tmp/CIS_77.tmp");
		$logger->debug("Command executed = find $path -ignore_readdir_race -xdev -type f \\( -perm -04000 -o -perm -02000 \\) >> /tmp/CIS_77.tmp");
	}

	# Comparing both results
        $req77_template = $cfg->param('77_cis_rogue_suid_template');
	$differences = `diff /tmp/CIS_77.tmp $req77_template`;
	chomp $differences;
	if ($differences ne "") {
                print ("Req. 7.7 Find Unauthorized SUID/SGID System Executables -> Comparing Result(\<) vs Template(\>)\n");
                $logger->info("Command Executed: diff /tmp/CIS_77.tmp " . $req77_template);
		$logger->info("There are differences for Requirement 7.7");
                print $differences . "\n";
                $logger->debug("Req. 7.7 Find Unauthorized SUID/SGID System Executables -> Comparing Result(\<) vs Template(\>)");
                $logger->debug($differences);
        }
        else {
                print ("Req. 7.7 Find Unauthorized SUID/SGID System Executables - No differences between Template and Result\n");
                $logger->info("Req. 7.7 Find Unauthorized SUID/SGID System Executables - No differences between Result and Template");
        }

	# ++++++++++++++++++++++++++++++++++++++++++++
   	# +  Requirement 7.8 Find All Unowned Files  +
   	# ++++++++++++++++++++++++++++++++++++++++++++
	# Look for this directories on the array @path_array
	foreach $path (@path_array) {
		chomp $path;
		system("find $path -ignore_readdir_race -xdev -type f -nouser -o -nogroup >> /tmp/CIS_78.tmp");
		$logger->debug("Command executed = find $path -ignore_readdir_race -type f -xdev -nouser -o -nogroup >> /tmp/CIS_78.tmp");
	}

	# Comparing both results
        $req78_template = $cfg->param('78_cis_unowned_template');
	$differences = `diff /tmp/CIS_78.tmp $req78_template`;
	chomp $differences;
	if ($differences ne "") {
                print ("Req. 7.8 Find All Unowned Files -> Comparing Result(\<) vs Template(\>)\n");
                $logger->info("Command Executed: diff /tmp/CIS_78.tmp " . $req78_template);
		$logger->info("There are differences for Requirement 7.8");
                print $differences . "\n";
                $logger->debug("Req. 7.8 Find All Unowned Files -> Comparing Result(\<) vs Template(\>)");
                $logger->debug($differences);
        }
        else {
                print ("Req. 7.8 Find All Unowned Files - No differences between Template and Result\n");
                $logger->info("Req. 7.8 Find All Unowned Files - No differences between Result and Template");
        }

	# Remove temporary files
	system("rm -rf /tmp/CIS*");
}

else {
	print ("Usage: Check_CIS.pm generate|check|showdiff LoggerConfPath ConfigPath\n");
}
