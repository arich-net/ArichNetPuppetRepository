# Definition: mkuser
#
# mkuser creates a user/group that can be realized in the module that employs it
#
# Parameters:
# $uid - UID of user
# $gid - GID of user, defaults to UID
# $group - group name of user, defaults to username
# $shell - user's shell, defaults to "/bin/bash"
# $home - home directory, defaults to /home/<username>
# $ensure - present by default
# $managehome - true by default
# $dotssh - creates ~/.ssh by default
# $comment - comment field for passwdany additional groups the user should be associated with
# $groups - any additional groups the user should be associated with
# $password - defaults to "!!"
# $symlink - use a symlink for the home directory
# $mode - mode of home directory, defaults to 700
#
# Actions: creates a user/group
#
# Requires:
# $uid
#
# Sample Usage:
# # create apachehup user and realize it
# @adduser { "apachehup":
# uid => "32001",
# gid => "32001",
# home => "/home/apachehup",
# managehome => "true",
# comment => "Apache Restart User",
# dotssh => "true",
# } # @adduser
#
# realize Generic::adduser[apachehup]
#
define adduser ($uid, $gid = undef, $group = undef, $shell = "/bin/bash", $home = undef, $ensure = "present", $managehome = true, $dotssh = "ensure", $comment = "created via puppet", $groups = undef, $password = "!!", $symlink = undef, $mode = undef) {

# if gid is unspecified, match with uid
 if $gid {
  $mygid = $gid
 } else {
  $mygid = $uid
 }

# if home is unspecified, use /home/<username>
 if $home {
  $myhome = $home
 } else {
  $myhome = "/home/$name"
 }

# if group is unspecified, use the username
 if $group {
  $mygroup = $group
 } else {
  $mygroup = $name
 }

# create user
 user { "$name":
  uid => "$uid",
  gid => "$mygid",
  shell => "$shell",
  groups => "$groups",
  password => "$password",
  managehome => "$managehome",
  home => "$myhome",
  ensure => "$ensure",
  comment => "$comment",
  require => Group["$name"],
 } # user

 group { "$name":
  gid => "$mygid",
  name => "$mygroup",
  ensure => "$ensure",
 } # group

# if link is passed a symlink will be used for ensure => , else we will make it a directory
 if $symlink {
  $myEnsure = $symlink
 } else {
  $myEnsure = "directory"
 }

# if mode is unspecified, use 700
 if $mode {
  $myMode = $mode
 } else {
  $myMode = "700"
 }

# create home dir
 file { "$myhome":
  ensure => $myEnsure,
  mode => $myMode,
  owner => $name,
  group => $name,
  require => User["$name"],
 } # file

# create ~/.ssh
 case $dotssh {
  "ensure","true": {
    file { "$myhome/.ssh":
     ensure => directory,
     mode => "700",
     owner => $name,
     group => $name,
     require => User["$name"],
    } # file
   } # 'ensure' or 'true'
  } # case

} # define adduser

# Definition: mkgroup
#
# mkgroup creates a group that can be realized in the module that employs it
#
# Parameters:
# $gid - GID of user, defaults to UID
#
# Actions: creates a group
#
# Requires:
# $gid
#
# Sample Usage:
# # create systems group and realize it
# @mkgroup { "systems":
# gid => "30000",
# } # @mkgroup
#
# realize Generic::Mkgroup[systems]
#
define addgroup ($gid) {
 group { "$name":
  ensure => present,
  gid => "$gid",
  name => "$name",
 } # group

} # define addgroup