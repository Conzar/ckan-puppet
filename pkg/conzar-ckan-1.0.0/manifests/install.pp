# installs ckan
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
class ckan::install {
  # install apache required for ckan package
  class {'apache': }
  class {'apache::mod::wsgi':}
  ## require supporting libs
  $ckan_libs = ['nginx','libpq5','python-pastescript']
  package { $ckan_libs:
    ensure => present,
  }
  # uses the preconfigured ubuntu repo
  if $ckan::is_ckan_from_repo == 'true' {
    package {'python-ckan':
      ensure  => latest,
      require => [Class['apache'],Package[$ckan_libs]],
    }
  }
  # installs the package from the specified source.
  else {
    package {'python-ckan':
      ensure   => latest,
      provider => dpkg,
      source   => "$ckan::ckan_package_dir/$ckan::ckan_package_filename",
      require  => [Class['apache'],Package[$ckan_libs]],
    }
  }
  package {'openjdk-6-jdk':
    ensure => present,
  }

  # === Jeta Installation  ===
  package {'solr-jetty':
    ensure  => present,
  }

  # === installation postgresql ===
  # note, may need to put a require here
  # for spatial extension
  include postgresql::server

  # === utility packages ===
  # need the latest version of nodejs in order to use
  # the ckan script bin/less
  #include 'apt'
  package { ['nodejs'] :
    ensure  => present,
  }

  # used to make an api request.
  package { 'python-pip' :
    ensure => present,
  }

  package { 'curl':
    ensure => present,
  }

  exec { 'download-npm':
    command =>
    "/usr/bin/curl https://npmjs.org/install.sh > $ckan::ckan_package_dir/npm_install.sh",
    creates => "$ckan::ckan_package_dir/npm_install.sh",
    require => Package['nodejs','curl'],
  }
  exec { 'install-npm':
    command => "/bin/sh $ckan::ckan_package_dir/npm_install.sh",
    cwd     => $ckan::ckan_package_dir,
    returns => [0,1,2],
    require => Exec['download-npm'],
    creates => '/usr/bin/npm',
  }
  # less requires a compile of the css before changes take effect.
  exec { 'install-nodewatch':
    command => '/usr/bin/npm install less nodewatch',
    cwd     => '/usr/lib/ckan/default/src/ckan',
    require => [Exec['install-npm'],
                Package['python-ckan'],],
    creates => '/usr/lib/ckan/default/src/ckan/bin/less',
  }
  # httpie can make the api call.
#  exec { 'install-httpie' :
#    command => '/usr/bin/pip install --upgrade httpie',
#    require => Package['python-pip'],
#  }
}
