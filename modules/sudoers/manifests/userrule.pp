define sudoers::userrule
(
  $user     = $name,
  $host     = 'ALL',
  $runas    = 'ALL',
  $options  = undef,
  $command  = '/bin/false',
  $separate = false
)
{

  # Validate the inputs
  validate_string( $user )
  validate_string( $host )
  validate_string( $runas )
  validate_string( $options )
  validate_string( $command )
  validate_bool( $separate )

  # Make sure options ends with a :
  if ( $options ) {
    $fixed_options = "${options}:"
  }
  else
  {
    $fixed_options = $options
  }

  $output = sprintf( "%s\t%s=(%s)\t%s\t%s", $user, $host, $runas, $fixed_options, $command )

  if ( $separate ) {
    # User file path
    $safe_user = regsubst( $user, '^%', 'g' )
    $user_file_path = "${sudoers::params::config_parts_dir}/${safe_user}"

    # The configuration file we'll be using
    concat { $user_file_path :
      owner => root,
      group => root,
      mode  => 0640,
    }

    concat::fragment{ "sudoers_config_${safe_user}":
      target  => $user_file_path,
      order   => 15,
      content => "${output}\n",
    }
  }
  else {
    concat::fragment{ "sudoers_config_${name}":
      target  => $sudoers::params::config,
      order   => 15,
      content => "${output}\n",
    }
  }
}
