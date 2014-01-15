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
  # the default image directory
  $ckan_img_dir   = '/usr/lib/ckan/default/src/ckan/ckan/public/base/images'
  $ckan_css_dir   = '/usr/lib/ckan/default/src/ckan/ckan/public/base/css'
  $license_file   = 'license.json'
  $backup_dir = '/backup'

  # ckan specific configuration files
  file {'/etc/apache2/sites-enabled/ckan_default':
    ensure  => present,
  }
  file {'/etc/apache2/sites-enabled/25-ckan.zen.landcareresearch.co.nz.conf':
    ensure  => present,
  }

  # === Jeta configuration ===
  file {'/etc/default/jetty':
    ensure  => file,
    source  => 'puppet:///modules/ckan/jetty',
  }
  # change default schema to use CKAN schema
  file {'/etc/solr/conf/schema.xml':
    ensure  => link,
    target  => '/usr/lib/ckan/default/src/ckan/ckan/config/solr/schema-2.0.xml',
  }

  file {[$ckan_etc,$ckan_default]:
    ensure  => directory,
  }
  file {"$ckan_default/production.ini":
    ensure  => file,
    content => template('ckan/production.erb'),
    require => File[$ckan_default],
    notify  => Exec['reload_apache'],
  }

  # Note, this is a hack to get around a huge
  # dependancy cycle between the install & config class
  # since install requires apache and config requires apache
  # for the apache notify
  exec { 'reload_apache':
    command     => '/usr/bin/service apache2 restart',
    # only run if notify is called
    refreshonly => true,
  }

  # add the logo but its set via the web ui and also set via production.ini
  # however, I'm not certain that the production.ini has any effect...
  if $site_logo != '' {
    file {"$ckan_img_dir/site_logo.png":
      ensure  => file,
      source  => $site_logo,
      require => File["$ckan_default/production.ini"],
      notify  => Exec['reload_apache'],
    }
  }
  $ckan_data_dir = ['/var/lib/ckan','/var/lib/ckan/default']
  file {$ckan_data_dir:
    ensure => directory,
    owner  => www-data,
    group  => www-data,
    mode   => '0755',
  }

  # download the license file if it exists
  if $ckan::license != '' {
    # add a license
    file {"$ckan_default/$license_file":
      ensure  => file,
      source  => $ckan::license,
    }
  }

  if $ckan::custom_imgs != '' {
    # manage the default image directory
    ckan::custom_images { $ckan::custom_imgs:
      notify  => Exec['reload_apache'],
    }
  }

  # download custom css if specified
  if $ckan::custom_css != 'main.css' {
    file {"$ckan_css_dir/custom.css":
      ensure  => file,
      source  => $ckan::custom_css,
      notify  => Exec['reload_apache'],
    }
  }

  # backup configuration
  file {$backup_dir:
    ensure => directory,
    owner  => backup,
    group  => backup,
    mode   => '0755',
  }
  file {'/usr/local/bin/ckan_backup.bash':
    ensure  => file,
    source  => 'puppet:///modules/ckan/ckan_backup.bash',
    mode    => '0755',
    require => File[$backup_dir],
  }

  # === api calls === #
  # create a vocabulary
#  exec { 'create_vocabulary' :
#    command  => '/usr/local/bin/http http://ckan.zen.landcareresearch.co.nz/api/3/action/vocabulary_create name=Discipline',
#    returns  => [0,1],
#  }
#  exec { 'create_botany_tag' :
#    command => '/usr/local/bin/http http://ckan.zen.landcareresearch.co.nz/api/3/action/tag_create name=Botany vocabulary_id=Discipline',
#    returns => [0,1],
#    require => Exec['create_vocabulary'],
#  }
#  exec { 'create_ecology_tag' :
#    command => '/usr/local/bin/http http://ckan.zen.landcareresearch.co.nz/api/3/action/tag_create name=Ecology vocabulary_id=Discipline',
#    returns => [0,1],
#    require => Exec['create_vocabulary'],
#  }
#  exec { 'create_genetics_tag' :
#    command => '/usr/local/bin/http http://ckan.zen.landcareresearch.co.nz/api/3/action/tag_create name=Genetics vocabulary_id=Discipline',
#    returns => [0,1],
#    require => Exec['create_vocabulary'],
#  }
#  exec { 'create_hydrology_tag' :
#    command => '/usr/local/bin/http http://ckan.zen.landcareresearch.co.nz/api/3/action/tag_create name=Hydrology vocabulary_id=Discipline',
#    returns => [0,1],
#    require => Exec['create_vocabulary'],
#  }
#  exec { 'create_informatics_tag' :
#    command => '/usr/local/bin/http http://ckan.zen.landcareresearch.co.nz/api/3/action/tag_create name=Informatics vocabulary_id=Discipline',
#    returns => [0,1],
#    require => Exec['create_vocabulary'],
#  }
#  exec { 'create_pedology_tag' :
#    command => '/usr/local/bin/http http://ckan.zen.landcareresearch.co.nz/api/3/action/tag_create name=Pedology vocabulary_id=Discipline',
#    returns => [0,1],
#    require => Exec['create_vocabulary'],
#  }
#  exec { 'create_systematics_tag' :
#    command => '/usr/local/bin/http http://ckan.zen.landcareresearch.co.nz/api/3/action/tag_create name=Systematics vocabulary_id=Discipline',
#    returns => [0,1],
#    require => Exec['create_vocabulary'],
#  }

#  file {'/var/local/ckan':
#    ensure  => directory,
#  }
#  file {'/var/local/ckan/images':
#    ensure  => directory,
#    require => File['/var/local/ckan'],
#  }
#  file {'/var/local/ckan/images/lcr_logo_white_sm.png':
#    ensure  => file,
#    source  => 'puppet:///modules/ckan/lcr_logo_white_sm.png',
#    require => File['/var/local/ckan/images'],
#  }

  # note, need to create a sys admin account
  # use the command
  # ckan sysadmin add <username>
  # . /usr/lib/ckan/default/bin/activate
  # cd /usr/lib/ckan/default/src/ckan
  # /usr/lib/ckan/default/src/ckan$ paster sysadmin add mcglinchya -c /etc/ckan/default/production.ini
  # update the log

}
