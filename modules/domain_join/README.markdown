[![Build Status](https://travis-ci.org/rnelson0/puppet-domain_join.png?branch=master)](https://travis-ci.org/rnelson0/puppet-domain_join)
[![Puppet Forge](http://img.shields.io/puppetforge/v/rnelson0/domain_join.svg)](https://forge.puppetlabs.com/rnelson0/domain_join)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/rnelson0/domain_join.svg)](https://forge.puppetlabs.com/rnelson0/domain_join)
[![Stories in Ready](https://badge.waffle.io/rnelson0/puppet-domain_join.svg?label=Ready&title=Ready)](http://waffle.io/rnelson0/puppet-modules)
[![Stories In Progress](https://badge.waffle.io/rnelson0/puppet-domain_join.svg?label=in%20progress&title=In%20Progress)](http://waffle.io/rnelson0/puppet-modules)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with domain_join](#setup)
    * [What domain_join affects](#what-domain_join-affects)
    * [Beginning with domain_join](#beginning-with-domain_join)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Creating a Least Privilege account](#creating-a-least-privilege-account)

## Overview

Provide the most minimal configuration required to allow a Linux node to join a Windows domain.

## Module Description

This module is intended for the lazy Linux admin who wants their Linux nodes to join a Windows domain without needing to manage the components. Rather than managing SSSD, Samba, and Kerberos, just manage "the ability to join a domain"!

Unfortunately, if you want to manage those services separately, this module may not be perfect fit for you. You may skip the service and resolver configuration by setting one or both of `manage_services` and `manage_resolver` to false.

## Setup

### What domain_join affects

* DNS resolution through `/etc/resolv.conf` unless `manage_resolver` is false.
* SSSD, Samba, and Kerberos configs (`/etc/sssd/sssd.conf`, `/etc/samba/smb.conf`, `/etc/krb5.conf`) unless `manage_services` is false.
* A domain join shell script at `/usr/local/bin/domain_join`, that includes credentials used to join the domain.
    * It is *highly* recommended that you follow the [Principle of Least Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilegehttps://en.wikipedia.org/wiki/Principle_of_least_privilege) and do *not* use a Domain Admin account or similar. See [Creating a Least Privilege Account](#creating-a-least-privilege-account) for more information.


### Beginning with domain_join

    # Without hiera
    class { 'domain_join':
      domain_fqdn               => 'example.com',
      domain_shortname          => 'example',
      ad_dns                    => ['10.0.0.1', '10.0.0.2'],
      register_account          => 'domainjoin',
      register_password         => 'Sup4rS3krEt',
      additional_search_domains => ['web.example.com', 'b2b.example.com'],
    }

    # With Hiera
    # Manifest:
    include domain_join
    
    # Hiera yaml:
    ---
    domain_join::domain_fqdn: example.com
    domain_join::domain_shortname: example
    domain_join::ad_dns:
      - 10.0.0.1
      - 10.0.0.2
    domain_join::register_account: domainjoin
    domain_join::register_password: 'Sup4rS3krEt'
    domain_join::additional_search_domains:
      - web.example.com
      - b2b.example.com

## Usage

Follow the above reference for simple domain joins. You can control the service and resolver configuration with two booleans:
    class { 'domain_join':
        ... # other options
        manage_services => false,
        manage_resolver => false,
    }

    ---
    domain_join::manage_services: false
    domain_join::manage_resolver: false

Additional configuration options include:

`createcomputer`: Name of the AD container to join the new node to, typically an OU or a built-in container object.

## Limitations

This module may cause duplicate resource errors if used in the same catalog as any module that directly manages sssd, samba, or kerberos packages or configs unless `manage_services` is false. See the compatibility tab or [metadata.json](metadata.json) for tested OS support.

## Creating a Least Privilege account
It is highly recommended that the `register_account` be an account that has the ability to join computers to domains and nothing else. The following is an overly simplistic method to create such a user. This is suitable for a lab but may need further review for use in production. Use at your own risk.
* Create an account, ex: **domainjoin**, in the appropriate hierarchy of your Active Directory. It is recommend that **User cannot change password** and **Password never expires** are selected.
* Delegate the ability to manage computer objects to the user with the *Active Directory Users and Computers* snap in (from [JSI Tip 8144](http://windowsitpro.com/windows-server/jsi-tip-8144-how-can-i-allow-ordinary-user-add-computer-domain) with tweaks).
 * Open the *Active Directory Users and Computers* snap-in.
 * Right click the container under which you want the computers added (ex: `Computers`) and choose *Delegate Control*.
 * Click *Next*.
 * Click *Add* and supply your user account(s), e.g **domainjoin**. Click *Next* when complete.
 * Select *Create custom task to delegate* and click *Next*.
 * Select *Only the following objects in the folder* and then *Computer objects*. Click *Next*.
 * Under **Permissions**, check *Create All Child Objects* and *Write All Properties*. Click *Next*.
 * Click *Finish*

You may also need to run the following command to [increase the Machine Account Quota to a very large number](https://technet.microsoft.com/en-us/library/dd391926%28v=ws.10%29.aspx). This represents the number of machines a user can join to the domain and defaults to 10 for the domain. This can only be set at the domain level.

    Set-ADDomain example.com -Replace @{"ms-ds-MachineAccountQuota"="10000"}
