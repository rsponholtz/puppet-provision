class sudoers::install
inherits sudoers
{

  package { $sudoers::package_name :
    ensure  => $sudoers::package_ensure,
  }

}
