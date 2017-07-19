require 'spec_helper'
describe 'domain_join', :type => :class do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      context 'with defaults for all parameters' do
        it { is_expected.to create_class('domain_join') }
        it { is_expected.to contain_package('oddjob-mkhomedir') }
        it { is_expected.to contain_package('krb5-workstation') }
        it { is_expected.to contain_package('krb5-libs') }
        it { is_expected.to contain_package('samba-common') }
    it { is_expected.to contain_package('samba-common-tools') }
        it { is_expected.to contain_package('sssd-ad') }
        it { is_expected.to contain_package('sssd-common') }
        it { is_expected.to contain_file('/etc/resolv.conf') }
        it { is_expected.to contain_file('/etc/krb5.conf') }
        it { is_expected.to contain_file('/etc/samba/smb.conf') }
        it { is_expected.to contain_file('/etc/sssd/sssd.conf') }
        it { is_expected.to contain_file('/usr/local/bin/domain-join') }
        it { is_expected.to contain_exec('join the domain') }
      end

      context 'with manage_services false' do
        let :params do
          {
            :manage_services => false,
          }
        end

        it { is_expected.not_to contain_package('sssd') }
        it { is_expected.not_to contain_file('/etc/sssd/sssd.conf') }
        it { is_expected.to contain_file('/etc/resolv.conf') }
        it { is_expected.to contain_file('/usr/local/bin/domain-join') }
      end

      context 'with manage_services and manage_resolver false' do
        let :params do
          {
            :manage_services => false,
            :manage_resolver => false,
          }
        end
        it { is_expected.not_to contain_package('sssd') }
        it { is_expected.not_to contain_file('/etc/sssd/sssd.conf') }
        it { is_expected.not_to contain_file('/etc/resolv.conf') }
        it { is_expected.to contain_file('/usr/local/bin/domain-join') }
      end

      context 'start script syntax' do
        case facts[:operatingsystemmajrelease]
        when '7'
          it { is_expected.to contain_file('/usr/local/bin/domain-join').with_content(/status sssd.service/)}
        else
          it { is_expected.to contain_file('/usr/local/bin/domain-join').with_content(/sssd status/)}
        end
      end

      context 'with container' do
        let :params do
          {
            :createcomputer => 'container',
          }
        end
        it { is_expected.to contain_file('/usr/local/bin/domain-join').with_content(/net ads join/) }
        it { is_expected.to contain_file('/usr/local/bin/domain-join').with_content(/container_ou='container'/) }
      end

      context 'with account and password' do
        let :params do
          {
            :register_account  => 'service_account',
            :register_password => 'open_sesame',
          }
        end
        it { is_expected.to contain_file('/usr/local/bin/domain-join').with_content(/register_account='service_account'/) }
        it { is_expected.to contain_file('/usr/local/bin/domain-join').with_content(/register_password='open_sesame'/) }
      end

      context 'with join_domain disabled' do
        let :params do
          {
            :join_domain => false,
          }
        end
        it { is_expected.not_to contain_exec('join the domain') }
      end

      context 'with manage_dns disabled' do
        it { is_expected.not_to contain_file('/usr/local/bin/domain-join').with_content(/net ads dns register/) }
        it { is_expected.not_to contain_file('/usr/local/bin/domain-join').with_content(/update add /) }
      end

      context 'with manage_dns and ptr enabled' do
        let :params do
          {
            :manage_dns  => true,
            :create_ptr  => true,
            :interface   => 'fake_interface',
          }
        end
        it { is_expected.to contain_file('/usr/local/bin/domain-join').with_content(/net ads dns register/) }
        it { is_expected.to contain_file('/usr/local/bin/domain-join').with_content(/update add .+ addr show fake_interface/) }
      end
    end
  end
end
