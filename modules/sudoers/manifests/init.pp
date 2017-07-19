class sudoers
(
  $config           = $sudoers::params::config,
  $config_parts_dir = $sudoers::params::config_parts_dir,
  $package_ensure   = $sudoers::params::package_ensure,
  $package_name     = $sudoers::params::package_name
)
inherits sudoers::params
{

  validate_string($config)
  validate_string($config_parts_dir)
  validate_string($package_ensure)
  validate_string($package_name)

  contain sudoers::install
  contain sudoers::modconfig
  
}
