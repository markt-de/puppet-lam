require 'spec_helper_acceptance'

describe 'lam' do
  context 'default parameters' do
    it 'is expected to work idempotently with no errors' do
      pp = <<-EOS
      if $facts['os']['family'] == "RedHat" {
        package { 'httpd':
            ensure => 'installed',
        }
      }
      else {
        package { 'apache2':
          ensure => 'installed',
        }
      }

      package { 'bzip2':
        ensure => 'installed',
      }

      class { 'lam':
        version => '8.2',
      }
      EOS

      idempotent_apply(pp)
    end
  end
end
