# azure_agent [![Build Status](https://travis-ci.org/kemra102/puppet-azure_agent.svg)](https://travis-ci.org/kemra102/puppet-azure_agent)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with azure_agent](#setup)
    * [What azure_agent affects](#what-azure_agent-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with azure_agent](#beginning-with-azure_agent)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - See who contributed to the module](#contributors)

## Overview

The Azure Linux Agent (**/usr/sbin/waagent**) manages interaction between a virtual machine and the Azure Fabric Controller. It does the following:

* Image Provisioning
  * Create a user account
  * Configure SSH authentication types
  * Deploy SSH public keys and key pairs
  * Sets the host name
  * Publishes the host name to the platform DNS
  * Reports SSH host key fingerprint to the platform
  * Manages the resource disk
  * Formats and mounts the resource disk
  * Configures swap space
* Networking
  * Manages routes to improve compatibility with platform DHCP servers
  * Ensures the stability of the network interface name
* Kernel
  * Configures virtual NUMA
  * Consumes Hyper-V entropy for /dev/random
  *  Configures SCSI timeouts for the root device (which could be remote)
* Diagnostics
  * Redirects the console to the serial port
* SCVMM Deployments
  * Detects and bootstraps the VMM agent for Linux when running in a System Center Virtual Machine Manager 2012 R2 environment
* VM Extension
  * Inject component authored by Microsoft and Partners into Linux VM (IaaS) to enable software and configuration automation
  * VM Extension reference implementation on [GitHub](https://github.com/Azure/azure-linux-extensions)

## Module Description

Deploy and manage the Azure agent on Linux instances.

## Setup

### What azure_agent affects

Manages following aspects of the [Microsoft Azure Linux agent](http://azure.microsoft.com/en-gb/documentation/articles/virtual-machines-linux-endorsed-distributions/):

* Azure agent package.
* Azure agent configuration.
* Azure agent service.

### Beginning with azure_agent

All variables have defaults so you can use the module simply like so:

```puppet
class { 'azure_agent': }
```

or

```yaml
include '::azure_agent'
```

## Usage

Config file settings can also be changed from the defaults if required:

```puppet
class { 'azure_agent':
  provisioning_sshhostkeypairtype => 'ecdsa',
  resourcedisk_filesystem         => 'xfs',
}
```

or via Hiera:

```yaml
---
classes:
  - azure_agent
azure_agent::provisioning_sshhostkeypairtype: 'ecdsa'
azure_agent::resourcedisk_filesystem: 'xfs'
```

## Reference

### Classes

#### Public Classes

* `::azure_agent`: Installs package, manages configuration and service.

#### Private Classes

* `::azure_agent::params`: Parameter class that other classes inherit from.

### Global Parameters

#### `package_name`

The package name to install.

Defaults:

* Ubuntu *operatingsystem*: `walinuxagent`
* Other *operatingsystem*: `WALinuxAgent`

#### `service_name`

The name of the Windows Azure Linux Agent.

Defaults:

* Ubuntu *operatingsystem*: `walinuxagent`
* Other *operatingsystem*: `waagent`

#### `provisioning_enabled`

This allows the user to enable or disable the provisioning functionality in the agent. Valid values are *y* or *n*. If provisioning is disabled, SSH host and user keys in the image are preserved and any configuration specified in the Azure provisioning API is ignored.

Defaults:

* Ubuntu *operatingsystem*: `n`
* Other *operatingsystem*: `y`

#### `provisioning_deleterootpassword`

If set, the root password in the **/etc/shadow** file is erased during the provisioning process.

Default: `n`

#### `provisioning_regeneratesshhostkeypair`

If set, all SSH host key pairs (ecdsa, dsa and rsa) are deleted during the provisioning process from **/etc/ssh/**. And a single fresh key pair is generated.

The encryption type for the fresh key pair is configurable by the Provisioning.SshHostKeyPairType entry. Please note that some distributions will re-create SSH key pairs for any missing encryption types when the SSH daemon is restarted (for example, upon a reboot).

Default: `y`

#### `provisioning_sshhostkeypairtype`

This can be set to an encryption algorithm type that is supported by the SSH daemon on the virtual machine. The typically supported values are **rsa**, **dsa** and **ecdsa**. Note that **putty.exe** on Windows does not support **ecdsa**. So, if you intend to use putty.exe on Windows to connect to a Linux deployment, please use **rsa** or **dsa**.

Default: `rsa`

#### `provisioning_monitorhostname`

If set, waagent will monitor the Linux virtual machine for hostname changes (as returned by the **hostname** command) and automatically update the networking configuration in the image to reflect the change. In order to push the name change to the DNS servers, networking will be restarted in the virtual machine. This will result in brief loss of Internet connectivity.

Default: `y`

#### `resourcedisk_format`

If set, the resource disk provided by the platform will be formatted and mounted by waagent if the filesystem type requested by the user in **ResourceDisk.Filesystem** is anything other than **ntfs**. A single partition of type Linux (83) will be made available on the disk. Note that this partition will not be formatted if it can be successfully mounted.

Default: `y`

#### `resourcedisk_filesystem`

This specifies the filesystem type for the resource disk. Supported values vary by Linux distribution. If the string is X, then mkfs.X should be present on the Linux image. SLES 11 images should typically use **ext3**.

Defaults:

* SLES *operatingsystem*: `ext3`
* Other *operatingsystem*: `ext4`

#### `resourcedisk_mountpoint`

This specifies the path at which the resource disk is mounted. Note that the resource disk is a temporary disk, and might be emptied when the VM is deprovisioned.

Default: `/mnt/resource`

#### `resourcedisk_enableswap`

If set, a swap file (**/swapfile**) is created on the resource disk and added to the system swap space.

Default: `n`

#### `resourcedisk_swapsizemb`

The size of the swap file in megabytes.

Default: `0`

#### `lbproberesponder`

If set, waagent will respond to load balancer probes from the platform (if present).

Default: `y`

#### `logs_verbose`

If set, log verbosity is boosted. Waagent logs to **/var/log/waagent.log** and leverages the system logrotate functionality to rotate logs.

Default: `n`

#### `os_rootdevicescsitimeout`

This configures the SCSI timeout in seconds on the OS disk and data drives. If not set, the system defaults are used.

Default: `300`

#### `os_opensslpath`

This can be used to specify an alternate path for the OpenSSL binary to use for cryptographic operations.

Default: `None`

## Limitations

This module has been tested as working on:

* Ubuntu 12.04.1+, 14.04 & 14.10.
* CentOS 6.4+, 7.
* OracleLinux 6.4+, 7.
* SLES 11 SP3+, 12.
* OpenSuSE 13.1, 13.2.

## Development

Contributions are welcome in any form, pull requests, and issues should be filed via GitHub.

## Contributors

The list of contributors can be found at: [https://github.com/kemra102/puppet-azure_agent/graphs/contributors](https://github.com/kemra102/puppet-azure_agent/graphs/contributors)
