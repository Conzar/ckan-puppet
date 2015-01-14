# == Class: ckanapi
#
# Installs the ckan commandline api
# Install Details: https://github.com/ckan/ckanapi
#
# Additional features:
# * Installs a helper script in /usr/bin/ckan/ckanapi.bash
#   which can be used to call ckanapi directly.
#
# === Parameters
#
# [*site_url*]
#   The url for the ckan site.
#
# === Authors
#
# Michael Speth <spethm@landcareresearch.co.nz>
#
# === Copyright
# GPL-3.0+
#
class ckan::ckanapi{

  $extdir = '/usr/lib/ckan/default/src/ckanapi'
  vcsrepo { $extdir:
    ensure   => 'present',
    provider => 'git',
    source   => 'git://github.com/ckan/ckanapi.git',
    revision => 'ckanapi-3.3',
  }
  exec { 'install ckanapi requirements':
    command     =>
    "/usr/lib/ckan/default/bin/pip install -r '${extdir}/requirements.txt'",
    onlyif      => "/usr/bin/test -e '${extdir}/requirements.txt'",
    refreshonly => true,
    subscribe   => Vcsrepo [$extdir],
  }
  exec { 'install ckanapi':
    command     => '/usr/lib/ckan/default/bin/python setup.py install',
    cwd         => $extdir,
    refreshonly => true,
    subscribe   => Exec['install ckanapi requirements'],
  }
  file { '/usr/local/bin/ckanapi.bash':
    ensure  => file,
    source  => 'puppet:///modules/ckan/ckanapi.bash',
    mode    => '0755',
    require => Exec['install ckanapi'],
  }
}