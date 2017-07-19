# == Class: host1fs
#
# Full description of class host1fs here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'host1fs':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class marsr-host1fs {


include lvm
#include sudoers  
#include '::azure_agent'

# make sure that the swap is configured properly - this is via the azure
# waagent that initializes the ephemeral disk when provisioning.
# should have 2x memory for swap.
class { 'azure_agent':
  resourcedisk_enableswap => 'y',
  resourcedisk_swapsizemb=> '27000',
}

physical_volume { '/dev/sdc':
   ensure => present,
}

volume_group { 'hanavg':
   ensure => present,
   physical_volumes => ['/dev/sdc'],
}

logical_volume { 'hanadatalv':
   ensure          => present,
   volume_group    => 'hanavg',
   size            => '10G',
}

logical_volume { 'hanaloglv':
   ensure          => present,
   volume_group    => 'hanavg',
   size            => '10G',
}

logical_volume { 'hanasharedlv':
   ensure          => present,
   volume_group    => 'hanavg',
   size            => '10G',
  require          => Volume_group['hanavg'],
}

filesystem { '/dev/hanavg/hanadatalv':
  ensure  => present,
  fs_type => 'xfs',
  require => Logical_volume['hanadatalv'],
}

filesystem { '/dev/hanavg/hanaloglv':
  ensure  => present,
  fs_type => 'xfs',
  require => Logical_volume['hanaloglv'],
}

filesystem { '/dev/hanavg/hanasharedlv':
  ensure  => present,
  fs_type => 'xfs',
  require => Logical_volume['hanasharedlv'],
}

mounts { 'Mount point for hanadatalv':
   ensure          => present,
   source          => '/dev/hanavg/hanadatalv',
   dest            => '/hana/data',
   type            => 'xfs',
   opts   => 'nofail,defaults,noatime',
   require => Filesystem['/dev/hanavg/hanadatalv'],
}

mounts { 'Mount point for hanaloglv':
   ensure          => present,
   source          => '/dev/hanavg/hanaloglv',
   dest            => '/hana/log',
   type            => 'xfs',
   opts   => 'nofail,defaults,noatime',
   require => Filesystem['/dev/hanavg/hanaloglv'],
}

mounts { 'Mount point for hanasharedlv':
   ensure          => present,
   source          => '/dev/hanavg/hanasharedlv',
   dest            => '/hana/shared',
   type            => 'xfs',
   opts   => 'nofail,defaults,noatime',
   require => Filesystem['/dev/hanavg/hanasharedlv'],
}

#sudoers::userrule{ 'anything_for_wheel' :
#  user    => '%SAPLAB\\linuxadmins',
#  command => 'ALL',
#}


}
