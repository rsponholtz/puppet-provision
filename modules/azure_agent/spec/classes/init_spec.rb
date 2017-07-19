require 'spec_helper'
describe 'azure_agent', :type => :class do
  context 'default parameters on Ubuntu' do
    let (:facts) {{ :operatingsystem => 'Ubuntu' }}
    it {
      should contain_class('azure_agent')
      should contain_package('walinuxagent').with_ensure('present')
      should contain_file('/etc/waagent.conf').with({
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
      should contain_file('/etc/waagent.conf').with_content(/^Provisioning.Enabled=n$/)
      should contain_file('/etc/waagent.conf').with_content(/^ResourceDisk.Filesystem=ext4$/)
      should contain_service('walinuxagent').with({
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasstatus'  => 'true',
        'hasrestart' => 'true',
      })
    }
  end
  context 'default parameters on SLES' do
    let (:facts) {{ :operatingsystem => 'SLES' }}
    it {
      should contain_package('WALinuxAgent')
      should contain_file('/etc/waagent.conf').with_content(/^Provisioning.Enabled=y$/)
      should contain_file('/etc/waagent.conf').with_content(/^ResourceDisk.Filesystem=ext3$/)
      should contain_service('waagent')
    }
  end
end
