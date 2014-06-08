# repos for ckan install
class ckan::repos {

  package {'python-software-properties':
    ensure => installed,
  }

  file {$ckan::ckan_package_dir:
    ensure => directory,
  }

  # downloads the package from the specified source.
  if $ckan::is_ckan_from_repo == false {
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
