# sudoers

This is a sudoers module indended to configure simple rules.

This is provided as-is, YMMV.


## Examples

Just include the module:

```
include sudoers
```

Do some configuration:

```
sudoers::config{ 'defaults_env_reset' :
  key     => 'Defaults',
  value   => 'env_reset',
}
```

Allow the wheel group to do anything:

```
sudoers::userrule{ 'anything_for_wheel' :
  user    => '%wheel',
  command => 'ALL',
}
```

Give the "vagrant" user password-less sudo:

```
sudoers::userrule { 'vagrant_sudo' :
  user    => 'vagrant',
  options => 'NOPASSWD',
  command => 'ALL'
}
```

Let the 'foo' group run 'ls' as the user 'foobar':

```
sudoers::userrule { 'ls_as_foobar' :
  user    => '%foo',
  command => 'ls',
  runas   => 'foobar',
}
```


## Contact

nospam@macwebb.com

If you send email, please include "sharumpe-sudoers" in the subject line.
