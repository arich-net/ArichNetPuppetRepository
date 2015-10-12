#!/bin/bash                                                                                                                                            
#!
#! Script to send automatic updates to Nexus
#! V1. Ariel Vasquez
#!
#!
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export http_proxy=http://evl3300858:3128
apt-get update
perl -I /usr/local/ntte/c336792/scripts/update/lib /usr/local/ntte/c336792/scripts/update/tool/UpdatesAvailableCheck.pl --config /usr/local/ntte/c336792/scripts/update/config/samples/Ubuntu1004/UpdatesAvailableCheck.config --ioc /usr/local/ntte/c336792/scripts/update/config/samples/Ubuntu1004/UpdatesAvailableCheck.ioc.config