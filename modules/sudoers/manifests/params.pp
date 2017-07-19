class sudoers::params
{
  $config           = '/etc/sudoers'
  $config_parts_dir = '/etc/sudoers.d'

  $package_ensure = present
  $package_name   = 'sudo'
}
