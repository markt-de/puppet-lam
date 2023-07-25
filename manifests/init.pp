# @summary Setup LDAP Account Manager (LAM)
#
# @param datadir
#   Specifies the directory where LAM should store its configuration
#   and other persistent data. A symlink is created in `$installroot`
#   that points to this directory. It should exist outside of `$installroot`.
#
# @param edition
#   The edition of LAM that should be installed.
#
# @param group
#   The name of the group that is used by the webserver process.
#
# @param installroot
#   Specifies the base directory where LAM should be installed. A new
#   subdirectory for each version will be created.
#
# @param manage_symlink
#    Enable maintaining a symlink that points to the current version.
#
# @param mirror
#   Specifies the base URL where the distribution archive can be downloaded.
#   Useful when providing a local mirror for the Pro edition.
#
# @param path
#   Set the $PATH environment variable.
#
# @param symlink_name
#    Name of the symlink if manage_symlink is set to true.
#
# @param user
#   The name of the user that is used by the webserver process.
#
# @param version
#   Specifies the version of LAM that should be installed.
#
class lam (
  Stdlib::Absolutepath $datadir,
  Enum['oss', 'pro'] $edition,
  String $group,
  Stdlib::Absolutepath $installroot,
  Boolean $manage_symlink,
  Variant[Stdlib::HTTPUrl,Stdlib::HTTPSUrl] $mirror,
  String $path,
  String $symlink_name,
  String $user,
  String $version,
) {
  class { 'lam::install': }
}
