# STENG PUPPET USAGE

## Puppet concepts

Puppet master is working in service-london. The puppet files are stored in a Subversion respository at
https://cfgweb.ntteo.net/svn/eng/puppet . This puppet setup is managed by Systems Engineering. They have a
lot of puppet code developed and, with time, this will become a service offered to our customers.

The Systems Eng team has achieved the multi-tenancy by means of a puppet concept, the _environments_. Every customer wanting to 
use puppet will have an environent to store his own puppet code. Also a lot of modules (re-usable components) are installed in
the global repository so customers will be also able to use them.  That being said, given the amount of time we have, it has 
been decided to limit the dependencies with the Systems Engineering team so we will not use any of the modules they provide.

The puppet directory structure is:

* PUPPETROOT
  * manifests: 
  * modules: modules available to everybody
  * environments: customer dedicated environments
      * c336792: Environment for **Systems Eng**. The number is the customer number in NEXUS.
      * c361768: Environment for **Storage Eng**. **WE ONLY MODIFY FILES FROM THIS DIRECTORY DOWN**
        * manifests: puppet entry point is here: site.pp
        * modules: our own modules
        * templates: our templates
        * files: our files

### Puppet execution

The puppet agent in installed by default on our build but, there is no scheduled execution and this is done on purpose. The puppet
agent needs to be executed by hand once we have uploaded (commited) the changes to the subversion.


## How to work

Being puppet code in a SVN repository, the way to work is always the same.

1. Ask Systems engineering to be granted write permission for the puppet environment c361768 **and read-only for everything else**.
1. Get our working-copy (check-out): 

    svn co https://cfgweb.ntteo.net/svn/eng/puppet/trunk directory-to-store-the-working-copy

1. Change anything you want in the **c361768** subdirectory. The directory structure in here matches the one seen above
1. Test anything we want
1. When we are ready, commit the changes, **only the c361768 subdirectory** 

    svn commit path-to-c361768

1. Go to the servers we want to apply changes and execute

    puppet agent --onetime --no-daemonize --no-splay --verbose

  * If you want to test before

    puppet agent --onetime --no-daemonize --no-splay --verbose --noop

1. If you want to continue working after some time, don't forget to get the latest updates from the repository. Maybe some
other colleague has commited changes also. From your working copy root dir, execute:

    svn update


## General systems build and configuration

One of the purposes of introducing puppet is to make the system easier to configure after the _build_. Our main goal is that, once
a system has finished the O/S install as per the NTTE tools, the rest of the configuration is done automatically via puppet. That
being said, there are specific points that are very dangerous to put under puppet management or, at least, to do it in a traditional 
way.  

Stages:

1. Initial: before the server is O/S built. 
  1. All relevant data will need to be collected at this point: PIP, OOB IP, hostname, container, etc.
2. Built: once the server has undergone the build process. It has an O/S and the default configuration
  1. The transition from Built to the next stage may be very simple or quite complex.
  2. For general servers, this will imply just to update the puppet environment in the puppet configuration file.
  3. In general, we need to ensure the device being built is able to access the Internet once the build process has finished. 
The puppet server is accessed through public networks.
3. Prod: once all the server has all the relevant configuration managed by puppet. Once again, It will need access 
to the puppet server to have its configuration managed since, as we said before, the puppet server is accessed through public networks.

# PUPPET-MANAGED BACKUP SERVERS

The backup servers have a number of specificities which make them very special when it comes to manage them:

  * All of them use an specific O/S version which is not going to change in the next years. We don't need any configuration to
be portable as of now. 
  * We have an specific build image in place that is is not going to change. We are completely aware of the status of the system
after the build.
  * The hostname of them will need to stay even though the container changes. Container and hostname, therefore, are not 
necessarily the same in these systems.
  * For backup migrations, it may meed to make these systems to change their IP addressing at some point of their life.
  * We want absolute control of the packages installed in every system. Because of this, we are going to forbid any system update

Let's see how the stages will look like for these devices.

## Initial stage

In this stage, the server is physically provisioned, powered on, etc. Our only concern here should be to:

* Have the server and the needed container and host names. They can be different. Internet access is, as always, needed
* Have a couple of IP addresses: PIP and OOB
* Have them located in a zone which internet connectivity 

## Built stage

This phase is a requisite from building a backup server.

* Needs to be built using a fixed distribution NTTE-Backup
* Needs to have internet connectivity

Once the server is built the _standard way_, we can proceed 


Steps

1. Ensure all the server configuration is updated in the puppet repository
1. Ensure the server is registered in the RHN
1. On the server we just built
  1. Ensure there are 6 ethernet devices
      * eth0 + eth1: Integrated controllers
      * eth2 + eth3: Emulex card on PCI3
      * eth4 + eth5: Emulex card on PCI4
      * modify the /etc/udev/rules.d/70-persistent-net-rules to ensure this works
      * Write down the mac addresses for them in a note in NEXUS
  1. Download the disk creation scripts
    * For a master: https://rebus.ntteo.net/util/masterdisks.sh
    * For a media: https://rebus.ntteo.net/util/mediadisks.sh
  1. Modify the /etc/puppet/puppet.conf file to point to the environment c361768 (our environment)
  1. Execute

    puppet agent --onetime --no-daemonize --no-splay --verbose

This should

1. Download the software via rsync from steng.ntteo.net and put it on /opt/NTTE/software
1. Modify the hosts
2. Modify the hostname (beware point before)
  * And reload it
2. Modify the resolv.conf
2. Modify the network configuration (including routes). Without restarting it
3. Manage the services below
  * ntp
  * sshd
  * smtp
  * users?
  * groups?
4. Copy all scripts to /usr/local/NTTE/steng
6. Disable the yum rhnplugin 
7. Add the rhn repository to yum http://rebus.ntteo.net/repos/backup/prod
2. Modify the sysctl.conf
2. Modify the kernel boot options
2. Modify the limits.conf

So, after executing puppet

1. halt the server
7. reconfigure the VLANS
8. Boot the server. It should boot right stright away the the proper network configuration and hostname.

## Prod stage

This is business as usual but no config change will be done directly. Only the points below will be manually managed:

* Software updates (yum ...)
* Disk management (create,delete of partitions, disks, etc)
* NB tasks

## Software updates

Software updates will be managed by ourselves. Main steps

1. For every server

  1. We will ensure the box is registered
  1. We will disable the redhat plugin from the configuration

2. For a specific server (in the lab?)

  1. We will install the download-only plugin in one of the servers or in the lab. This makes yum to download the packages, 
not install them
  3. We will install the createrepo plugin the same way

4. In this server, once every few months we will:

  1. Enable the redhat plugin
  2. Execute an update with downloadonly. This will download all the packages
  3. Create / update a repository with these packages. Publish it in rebus.ntteo.net as rebus.ntteo.net/repos/backup/test
  4. This will mean we have a repository with the packages we need to update the systems

5. Once this is tested, we will ensure all the servers have rebus.ntteo.net/repos/backup/prod as an authorized repository
6. We will copy rebus.ntteo.net/repos/backup/test to rebus.ntteo.net/repost/backup/prod
6. We will _yum update_ all of them 
7. All the servers will have all the same packages

Important to note: no package will be installed unless it comes from this repository.


