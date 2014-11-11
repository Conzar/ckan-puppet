# == Type: ckan::ext
#
# A type which can be used to install a CKAN extension in the default location.
#
# === Parameters
#
# [*extname*]
#   The name of the extension. Defaults to $title.
#
# [*provider*]
#   The name of the VCS repository provider where the extension is hosted. Can
#   be any provider supported by puppetlabs/vcsrepo. Defaults to 'git'.
#
# [*source*]
#   The URL of the remote VCS repository. Defaults to
#   "git://github.com/ckan/ckanext-$extname.git".
#
# [*revision*]
#   The revision of the VCS repository to check out and install. Defaults to
#   "stable".
#
define ckan::ext(
  $extname = undef,
  $provider = 'git',
  $source = undef,
  $revision = 'stable',
) {
  if ! defined(Class['ckan']) {
    fail('You must include the ckan base class before using any ckan defined resources')
  }

  if $extname == undef {
    $_extname = $title
  } else {
    $_extname = $extname
  }

  if $source == undef {
    $_source = "git://github.com/ckan/ckanext-${_extname}.git"
  } else {
    $_source = $source
  }

  $extdir = "/usr/lib/ckan/default/src/ckanext-${_extname}"

  vcsrepo { $extdir:
    ensure   => 'present',
    provider => $provider,
    source   => $_source,
    revision => $revision,
  } ~>
  exec { "install ckanext-${_extname}":
    command     => "/usr/lib/ckan/default/bin/pip install -e '${extdir}'",
    refreshonly => true,
  } ~>
  exec { "install ckanext-${_extname} requirements":
    command     => "/usr/lib/ckan/default/bin/pip install -r '${extdir}/pip-requirements.txt'",
    onlyif      => "/usr/bin/test -e '${extdir}/pip-requirements.txt'",
    refreshonly => true,
  }
}
