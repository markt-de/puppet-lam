require 'spec_helper'

describe 'lam' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:archive_name) { 'ldap-account-manager-7.3.tar.bz2' }
      let(:data_dir) { '/opt/lam-data' }
      let(:data_dir_alt) { '/data/lam-data' }
      let(:dist_dir) { 'ldap-account-manager-7.3' }
      let(:install_root) { '/opt' }
      let(:install_root_alt) { '/mnt' }
      let(:lam_group) do
        case facts[:os]['family']
        when 'Debian'
          'www-data'
        when 'FreeBSD'
          'www'
        when 'RedHat'
          'apache'
        end
      end
      let(:lam_user) do
        case facts[:os]['family']
        when 'Debian'
          'www-data'
        when 'FreeBSD'
          'www'
        when 'RedHat'
          'apache'
        end
      end
      let(:lam_version) { '7.3' }
      let(:symlink_name) { '/opt/lam' }

      context 'with only required parameters' do
        let(:params) do
          {
            version: lam_version,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('lam::install') }

        it {
          is_expected.to contain_archive("#{install_root}/#{archive_name}").with(
            source: "http://prdownloads.sourceforge.net/lam/#{archive_name}?download",
            extract: true,
            extract_path: install_root,
            creates: "#{install_root}/#{dist_dir}",
            cleanup: false,
          )
        }

        it {
          is_expected.to contain_exec("Initialize LAM data directory #{data_dir}").with(
            command: "mv #{install_root}/#{dist_dir}/config #{data_dir}/ && ln -s #{data_dir}/config #{install_root}/#{dist_dir}/",
            onlyif: "test ! -d #{data_dir}/config",
          )
        }

        it {
          is_expected.to contain_exec('Setup initial LAM configuration').with(
            command: "cp #{data_dir}/config/config.cfg.sample #{data_dir}/config/config.cfg",
            onlyif: "test ! -f #{data_dir}/config/config.cfg",
          )
        }

        it {
          is_expected.to contain_exec("Activate LAM data directory for version #{lam_version}").with(
            command: "mv #{install_root}/#{dist_dir}/config #{install_root}/#{dist_dir}/config.dist && ln -s #{data_dir}/config #{install_root}/#{dist_dir}/",
            onlyif: "test -d #{data_dir}/config && test ! -L #{install_root}/#{dist_dir}/config",
            refreshonly: true,
          ).that_subscribes_to("Archive[#{install_root}/#{archive_name}]")
        }

        it {
          is_expected.to contain_exec('Fix permissions of LAM installation').with(
            command: "chown -R #{lam_user}:#{lam_group} #{data_dir}/config #{install_root}/#{dist_dir}/sess #{install_root}/#{dist_dir}/tmp",
            refreshonly: true,
          ).that_subscribes_to("Archive[#{install_root}/#{archive_name}]")
        }

        it {
          is_expected.to contain_file(symlink_name).with(
            ensure: 'link',
            target: "#{install_root}/#{dist_dir}",
          ).that_requires("Archive[#{install_root}/#{archive_name}]")
        }
      end

      context 'with custom parameters' do
        let(:params) do
          {
            datadir: '/data/lam-data',
            installroot: '/mnt',
            manage_symlink: false,
            version: lam_version,
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_archive("#{install_root_alt}/#{archive_name}").with(
            extract_path: install_root_alt,
            creates: "#{install_root_alt}/#{dist_dir}",
          )
        }

        it {
          is_expected.to contain_exec('Fix permissions of LAM installation').with(
            command: "chown -R #{lam_user}:#{lam_group} #{data_dir_alt}/config #{install_root_alt}/#{dist_dir}/sess #{install_root_alt}/#{dist_dir}/tmp",
          )
        }

        it {
          is_expected.not_to contain_file(symlink_name).with(
            ensure: 'link',
          )
        }
      end
    end
  end
end
