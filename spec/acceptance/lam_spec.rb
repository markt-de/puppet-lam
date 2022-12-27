require 'spec_helper_acceptance'

describe 'lam' do
  context 'default parameters' do
    it 'is expected to work idempotently with no errors' do
      pp = <<-EOS
      if $facts['os']['family'] == "RedHat" {
        package { 'httpd':
            ensure => 'installed',
        }
        $user_name = 'apache'
        $group_name = 'apache'
      }
      else {
        package { 'apache2':
            ensure => 'installed',
        }
        $user_name = 'www-data'
        $group_name = 'www-data'
      }

      package { 'bzip2':
        ensure => 'installed',
      }

      class { 'lam':
        datadir        => '/opt/lam-data',
        edition        => 'oss',
        group          => $group_name,
        installroot    => '/opt',
        manage_symlink => true,
        mirror         => 'http://prdownloads.sourceforge.net/lam/%s?download',
        path           => '/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin',
        symlink_name   => 'lam',
        user           => $user_name,
        version        => '8.2',
      }
      EOS

      idempotent_apply(pp)
    end
  end
end
