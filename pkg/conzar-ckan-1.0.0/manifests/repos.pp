# repos for ckan install
class ckan::repos {

  class {'apt':
    always_apt_update => true,
  }

  package {'python-software-properties':
    ensure => installed,
  }

  # ppa's for default ckan install
  apt::ppa { 'ppa:chris-lea/node.js':
    require => Package['python-software-properties'],
  }
  # ppa's for extensions
  apt::ppa { 'ppa:ubuntugis':
    require => Package['python-software-properties'],
  }

  # downloads the package from the specified source.
  if $ckan::is_ckan_from_repo == 'false' {
    file {$ckan::ckan_package_dir:
      ensure => directory,
    }
    include wget
    wget::fetch { 'Download ckan package':
      source      => $ckan::ckan_package_url,
      destination => "$ckan::ckan_package_dir/$ckan::ckan_package_filename",
      timeout     => 0,
      verbose     => false,
      require     => File[$ckan::ckan_package_dir],
    }
  }
}
