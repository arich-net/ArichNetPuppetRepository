#!/bin/bash
#!
#! Script to apply puppet changes
#! V1. Ariel Vasquez
#!
#!
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export http_proxy=http://evl3300858:3128

puppetd --onetime --verbose --no-daemonize --show_diff --debug --logdest /var/log/puppet/puppet.log
