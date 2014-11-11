# configuration supporting ckan
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
class ckan::config (
  $site_url,
  $site_title,
  $site_description,
  $site_intro,
  $site_about,
  $site_logo,
  $plugins,
){

  # == variables ==
  # the configuration directories
  $ckan_etc       = '/etc/ckan'
  $ckan_default   = "$ckan_etc/default"
  $ckan_src       = '/usr/lib/ckan/default/src/ckan'
  # the default image directory
  $ckan_img_dir   = "$ckan_src/ckan/public/base/images"
  $ckan_css_dir   = "$ckan_src/ckan/public/base/css"
  $ckan_storage_path = '/var/lib/ckan/default'
  $license_file   = 'license.json'
  $backup_dir = '/backup'

  # Jetty configuration
  file {'/etc/default/jetty':
    ensure  => file,
    source  => 'puppet:///modules/ckan/jetty',
  }
  # Change default schema to use CKAN schema
  file {'/etc/solr/conf/schema.xml':
    ensure  => link,
    target  => "$ckan_src/ckan/config/solr/schema-2.0.xml",
  }

  # CKAN configuration
  file { [$ckan_etc, $ckan_default]:
    ensure  => directory,
  }

  concat { "$ckan_default/production.ini":
     owner => root,
     group => root,
     mode  => '0644',
  }
  concat::fragment { "config_head":
    target  => "$ckan_default/production.ini",
    content => template('ckan/production_head.ini.erb'),
    order   => 01,
  }
  concat::fragment { "config_tail":
    target  => "$ckan_default/production.ini",
    content => template('ckan/production_tail.ini.erb'),
    order   => 99,
  }

  # add the logo but its set via the web ui and also set via production.ini
  # however, I'm not certain that the production.ini has any effect...
  if $site_logo != '' {
    file {"$ckan_img_dir/site_logo.png":
      ensure  => file,
      source  => $site_logo,
      require => File["$ckan_default/production.ini"],
    }
  }
  $ckan_data_dir = ['/var/lib/ckan',$ckan_storage_path]
  file {$ckan_data_dir:
    ensure => directory,
    owner  => www-data,
    group  => www-data,
    mode   => '0755',
  }

  # download the license file if it exists
  if $ckan::license != '' {
    # add a license
    file { "$ckan_default/$license_file":
      ensure => file,
      source => $ckan::license,
    }
  }

  if $ckan::custom_imgs != '' {
    # manage the default image directory
    ckan::custom_images { $ckan::custom_imgs: }
  }

  # download custom css if specified
  if $ckan::custom_css != 'main.css' {
    file {"$ckan_css_dir/custom.css":
      ensure => file,
      source => $ckan::custom_css,
    }
  }

  # backup configuration
  file { $backup_dir:
    ensure => directory,
    owner  => backup,
    group  => backup,
    mode   => '0755',
  }
  file { '/usr/local/bin/ckan_backup.bash':
    ensure  => file,
    source  => 'puppet:///modules/ckan/ckan_backup.bash',
    mode    => '0755',
    require => File[$backup_dir],
  }
  cron {'ckan_backup':
    command => '/usr/local/bin/ckan_backup.bash',
    user    => backup,
    minute  => '0',
    hour    => '5',
    weekday => '7',
  }
}
