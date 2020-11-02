# @summary Download and extract the distribution archive
# @api private
class lam::install {
  assert_private()

  include 'archive'

  $distribution_dir = "ldap-account-manager-${lam::version}"
  $archive_name = "${distribution_dir}.tar.bz2"
  $download_url = sprintf($lam::mirror, $archive_name)
  $install_dir = "${lam::installroot}/${distribution_dir}"

  archive { "${lam::installroot}/${archive_name}":
    source       => $download_url,
    extract      => true,
    extract_path => $lam::installroot,
    creates      => $install_dir,
    cleanup      => false,
  }

  # Create LAM data directory.
  file { $lam::datadir:
    ensure => directory,
    group  => $lam::group,
    owner  => $lam::user,
  }

  # Initialize the data directory by copying the default configs.
  -> exec { "Initialize LAM data directory ${lam::datadir}":
    command => "mv ${install_dir}/config ${lam::datadir}/ && ln -s ${lam::datadir}/config ${install_dir}/",
    path    => $lam::path,
    onlyif  => "test ! -d ${lam::datadir}/config",
  }

  # Install default configuration if no configuration can be found.
  -> exec { 'Setup initial LAM configuration':
    command => "cp ${lam::datadir}/config/config.cfg.sample ${lam::datadir}/config/config.cfg",
    path    => $lam::path,
    onlyif  => "test ! -f ${lam::datadir}/config/config.cfg",
  }

  # Restore LAM data by replacing the default config directory
  # with a symlink to the actual data directory. The default directory
  # is preserved for safekeeping.
  -> exec { "Activate LAM data directory for version ${lam::version}":
    command     => "mv ${install_dir}/config ${install_dir}/config.dist && ln -s ${lam::datadir}/config ${install_dir}/",
    path        => $lam::path,
    onlyif      => "test -d ${lam::datadir}/config && test ! -L ${install_dir}/config",
    refreshonly => true,
    subscribe   => [
      Archive["${lam::installroot}/${archive_name}"],
    ],
  }

  # LAM requires that several files and folders are writable.
  -> exec { 'Fix permissions of LAM installation':
    command     => "chown -R ${lam::user}:${lam::group} ${lam::datadir}/config ${install_dir}/sess ${install_dir}/tmp",
    path        => $lam::path,
    refreshonly => true,
    subscribe   => [
      Archive["${lam::installroot}/${archive_name}"],
    ],
  }

  # Maintain a symlink that points to the current version.
  if ($lam::manage_symlink) {
    file { "${lam::installroot}/${lam::symlink_name}":
      ensure  => link,
      target  => $install_dir,
      require => [
        Archive["${lam::installroot}/${archive_name}"],
        Exec["Initialize LAM data directory ${lam::datadir}"],
        Exec["Activate LAM data directory for version ${lam::version}"],
      ],
    }
  }
}
