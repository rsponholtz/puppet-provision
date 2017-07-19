# == Class: azure_agent
#
# Deploy and manage the Azure agent on Linux instances.
#
# === Parameters
#
# [*package_name*]
#   The package name to install.
#
# [*provisioning_enabled*]
#   This allows the user to enable or disable the provisioning functionality
#   in the agent. Valid values are 'y' or 'n'. If provisioning is disabled,
#   SSH host and user keys in the image are preserved and any configuration
#   specified in the Azure provisioning API is ignored.
#
# [*provisioning_deleterootpassword*]
#   If set, the root password in the /etc/shadow file is erased during the
#   provisioning process.
#
# [*provisioning_regeneratesshhostkeypair*]
#   If set, all SSH host key pairs (ecdsa, dsa and rsa) are deleted during the
#   provisioning process from /etc/ssh/. And a single fresh key pair is
#   generated.
#
#   The encryption type for the fresh key pair is configurable by the
#   Provisioning.SshHostKeyPairType entry. Please note that some distributions
#   will re-create SSH key pairs for any missing encryption types when the SSH
#   daemon is restarted (for example, upon a reboot).
#
# [*provisioning_sshhostkeypairtype*]
#   This can be set to an encryption algorithm type that is supported by the
#   SSH daemon on the virtual machine. The typically supported values are rsa,
#   dsa and ecdsa. Note that putty.exe on Windows does not support ecdsa. So,
#   if you intend to use putty.exe on Windows to connect to a Linux deployment,
#   please use rsa or dsa.
#
# [*provisioning_monitorhostname*]
#   If set, waagent will monitor the Linux virtual machine for hostname
#   changes (as returned by the hostname command) and automatically update
#   the networking configuration in the image to reflect the change. In order
#   to push the name change to the DNS servers, networking will be restarted
#   in the virtual machine. This will result in brief loss of Internet
#   connectivity.
#
# [*resourcedisk_format*]
#   If set, the resource disk provided by the platform will be formatted and
#   mounted by waagent if the filesystem type requested by the user in
#   ResourceDisk.Filesystem is anything other than ntfs. A single partition of
#  type Linux (83) will be made available on the disk. Note that this partition
#   will not be formatted if it can be successfully mounted.
#
# [*resourcedisk_filesystem*]
#   This specifies the filesystem type for the resource disk. Supported values
#   vary by Linux distribution. If the string is X, then mkfs.X should be
#   present on the Linux image. SLES 11 images should typically use ext3.
#
# [*resourcedisk_mountpoint*]
#   This specifies the path at which the resource disk is mounted. Note that
#   the resource disk is a temporary disk, and might be emptied when the VM
#   is deprovisioned.
#
# [*resourcedisk_enableswap*]
#   If set, a swap file (/swapfile) is created on the resource disk and added
#   to the system swap space.
#
# [*resourcedisk_swapsizemb*]
#   The size of the swap file in megabytes.
#
# [*lbproberesponder*]
#   If set, waagent will respond to load balancer probes from the platform
#   (if present).
#
# [*logs_verbose*]
#   If set, log verbosity is boosted. Waagent logs to /var/log/waagent.log
#   and leverages the system logrotate functionality to rotate logs.
#
# [*os_rootdevicescsitimeout*]
#   This configures the SCSI timeout in seconds on the OS disk and data drives.
#   If not set, the system defaults are used.
#
# [*os_opensslpath*]
#   This can be used to specify an alternate path for the OpenSSL binary to
#   use for cryptographic operations.
#
# === Examples
#
#  class { 'azure_agent':
#    provisioning_sshhostkeypairtype => 'ecdsa',
#    resourcedisk_filesystem         => 'xfs',
#  }
#
# === Authors
#
# Danny Roberts <danny@thefallenphoenix.net>
#
# === Copyright
#
# Copyright 2015 Danny Roberts
#
class azure_agent (

  $package_name                          = $::azure_agent::params::package_name,
  $service_name                          = $::azure_agent::params::service_name,

  $provisioning_enabled                  = $::azure_agent::params::provisioning_enabled,
  $provisioning_deleterootpassword       = $::azure_agent::params::provisioning_deleterootpassword,
  $provisioning_regeneratesshhostkeypair = $::azure_agent::params::provisioning_regeneratesshhostkeypair,
  $provisioning_sshhostkeypairtype       = $::azure_agent::params::provisioning_sshhostkeypairtype,
  $provisioning_monitorhostname          = $::azure_agent::params::provisioning_monitorhostname,
  $resourcedisk_format                   = $::azure_agent::params::resourcedisk_format,
  $resourcedisk_filesystem               = $::azure_agent::params::resourcedisk_filesystem,
  $resourcedisk_mountpoint               = $::azure_agent::params::resourcedisk_mountpoint,
  $resourcedisk_enableswap               = $::azure_agent::params::resourcedisk_enableswap,
  $resourcedisk_swapsizemb               = $::azure_agent::params::resourcedisk_swapsizemb,
  $lbproberesponder                      = $::azure_agent::params::lbproberesponder,
  $logs_verbose                          = $::azure_agent::params::logs_verbose,
  $os_rootdevicescsitimeout              = $::azure_agent::params::os_rootdevicescsitimeout,
  $os_opensslpath                        = $::azure_agent::params::os_opensslpath,

) inherits azure_agent::params {

  validate_string($package_name)
  validate_string($service_name)
  validate_re($provisioning_enabled, '^(y|n)$',
    "${provisioning_enabled} is not supported for provisioning_enabled. Allowed values are 'y' & 'n'.")
  validate_re($provisioning_deleterootpassword, '^(y|n)$',
    "${provisioning_deleterootpassword} is not supported for provisioning_deleterootpassword. Allowed values are 'y' & 'n'.")
  validate_re($provisioning_regeneratesshhostkeypair, '^(y|n)$',
    "${provisioning_regeneratesshhostkeypair} is not supported for provisioning_regeneratesshhostkeypair. Allowed values are 'y' & 'n'.")
  validate_re($provisioning_sshhostkeypairtype, '^(rsa|dsa|ecdsa)$',
    "${provisioning_sshhostkeypairtype} is not supported for provisioning_sshhostkeypairtype. Allowed values are 'rsa', 'dsa' & 'ecdsa'.")
  validate_re($provisioning_monitorhostname, '^(y|n)$',
    "${provisioning_monitorhostname} is not supported for provisioning_monitorhostname. Allowed values are 'y' & 'n'.")
  validate_re($resourcedisk_format, '^(y|n)$',
    "${resourcedisk_format} is not supported for resourcedisk_format. Allowed values are 'y' & 'n'.")
  validate_string($resourcedisk_filesystem)
  validate_absolute_path($resourcedisk_mountpoint)
  validate_re($resourcedisk_enableswap, '^(y|n)$',
    "${resourcedisk_enableswap} is not supported for resourcedisk_enableswap. Allowed values are 'y' & 'n'.")
  validate_integer($resourcedisk_swapsizemb)
  validate_re($lbproberesponder, '^(y|n)$',
    "${lbproberesponder} is not supported for lbproberesponder. Allowed values are 'y' & 'n'.")
  validate_re($logs_verbose, '^(y|n)$',
    "${logs_verbose} is not supported for logs_verbose. Allowed values are 'y' & 'n'.")
  validate_integer($os_rootdevicescsitimeout)
  validate_string($os_opensslpath)

#  package { $package_name:
#    ensure => 'present',
#    before => File['/etc/waagent.conf'],
#  }

  file { '/etc/waagent.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('azure_agent/waagent.conf.erb'),
    notify  => Service['waagent'],
  }

  service { $service_name:
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    alias      => 'waagent',
  }

}
