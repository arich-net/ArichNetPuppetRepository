####Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with na_stdlib](#setup)
    * [What na_stdlib affects](#what-na_stdlib-affects)
    * [Beginning with na_stdlib](#beginning-with-na_stdlib)
4. [Reference](#reference)

##Overview

Standard library extensions for NTTEAM puppet modules, it doesn't replace
puppetlabs/stdlib but extends it (depending on it). Add a dependency to it to
your modules instead of puppetlabs/stdlib.

##Setup

###What na_stdlib affects

Right now it only includes some functions, so see their documentation.

###Beginning with na_stdlib

Just install the module.

##Reference

### Functions

mkdir_p
-------
This function will create a directory recursively with the given directory
definition until it gets an existent parent. It delegates to
[stdlib ensure_resurce](https://github.com/puppetlabs/puppetlabs-stdlib#ensure_resource).
