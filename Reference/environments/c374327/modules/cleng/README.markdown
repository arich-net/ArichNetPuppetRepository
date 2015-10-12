####Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with cleng](#setup)
    * [What cleng affects](#what-cleng-affects)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

##Overview

NTTEAM CLENG repository management.

##Setup

###What cleng affects

Install CLENG repository for all supported OS, all packages included are
prefixed with _cleng_ prefix and are installed into its own directories.

##Usage

Just include the class and ensure any package depending on it defines the
dependency:

```puppet
class myclass {
  include 'cleng'

  package { 'cleng-some-package':
    require => Class['cleng'],
  }
```

##Limitations

OS supported list:

* CentOS 6.5
