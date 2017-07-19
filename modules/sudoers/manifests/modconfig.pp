class sudoers::modconfig
inherits sudoers
{

  # The configuration file we'll be using
  concat { $sudoers::config :
    owner => root,
    group => root,
    mode  => 0640,
  }

  concat::fragment { 'puppet_warning' :
    target  => $sudoers::config,
    order   => 01,
    content => "# Managed by Puppet. Changes will be lost!\n",
  }

  concat::fragment { 'include_sudoers_d' :
    target  => $sudoers::config,
    order   => 99,
    content => "\n#includedir /etc/sudoers.d\n"
  }

}
