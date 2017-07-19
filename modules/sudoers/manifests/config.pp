define sudoers::config
(
  $key,
  $value
)
{

  # Validate the inputs
  validate_string( $key )
  validate_string( $value )

  $output = join( [ $key, $value], "\t" )

  concat::fragment{ "sudoers_config_${name}":
    target  => $sudoers::params::config,
    order   => 10,
    content => "${output}\n",
  }
}
