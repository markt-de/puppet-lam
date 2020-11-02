# puppet-lam

[![Build Status](https://travis-ci.org/markt-de/puppet-lam.png?branch=master)](https://travis-ci.org/markt-de/puppet-lam)
[![Puppet Forge](https://img.shields.io/puppetforge/v/fraenki/lam.svg)](https://forge.puppetlabs.com/fraenki/lam)
[![Puppet Forge](https://img.shields.io/puppetforge/f/fraenki/lam.svg)](https://forge.puppetlabs.com/fraenki/lam)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Usage](#usage)
    - [Basic usage](#basic-usage)
    - [Pro edition](#pro-edition)
1. [Reference](#reference)
1. [Development](#development)
    - [Contributing](#contributing)

## Overview

A puppet module to install and configure [LDAP Account Manager (LAM)](https://github.com/LDAPAccountManager/lam), a webfrontend for managing entries stored in an LDAP directory.

## Requirements

A working PHP installation as well as a properly configured webserver are required.

Both [puppet-php](https://github.com/voxpupuli/puppet-php/) as well as [puppetlabs-apache](https://github.com/puppetlabs/puppetlabs-apache/) are highly recommended to setup a functional environment. This task is beyond the scope of this module.

## Usage

### Basic usage

The minimum configuration should at least specify the desired version:

```puppet
class { 'lam':
  version => '7.3',
}
```

This will install and configure LAM. You should use the symlink target (which defaults to `/opt/lam`) as the document root when setting up the webserver.

LAM needs write access to several directories, so if your webserver runs with a different user account, you should specify the following additional parameters:

```puppet
class { 'lam':
  group   => 'wwwgroup',
  user    => 'wwwuser',
  version => '7.3',
}
```

The module maintains a dedicated data directory for LAM, so configuration and runtime data is not lost when upgrading. The location of this directory can be customized:

```puppet
class { 'lam':
  datadir => '/path/to/lam-data',
  version => '7.3',
}
```

### Pro edition

In theory the Pro edition of LAM is supported by the `$edition` parameter. You need to download it from the customer portal and place the archive on a local mirror, which should later be specified by using the `$mirror` parameter.

However, due to the lack of a test license this feature is untested.

```puppet
class { 'lam':
  edition => 'pro',
  mirror  => 'http://company.example.com/path/to/archive/%s',
  version => '7.3',
}
```

## Reference

Classes and parameters are documented in [REFERENCE.md](REFERENCE.md).

## Development

### Contributing

Please use the GitHub issues functionality to report any bugs or requests for new features. Feel free to fork and submit pull requests for potential contributions.

Contributions must pass all existing tests, new features should provide additional unit/acceptance tests.
