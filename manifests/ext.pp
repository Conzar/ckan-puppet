define ckan::ext(
  $extname = undef,
  $ensure = 'present',
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
    ensure   => $ensure,
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
