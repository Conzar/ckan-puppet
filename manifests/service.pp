# manages services for ckan
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
class ckan::service {

  # note dependancies
  # Jetty -> Apache -> Nginx
  # === Jeta Service === #
  service {'jetty':
    ensure    => running,
    subscribe => File['/etc/default/jetty','/etc/solr/conf/schema.xml'],
  }
  # === Nginx service === #
  service {'nginx':
    ensure    => running,
    subscribe => Service['jetty'],
  }

  # === postgresql ===
  include check_run
  # initialize the database with ckan
#  exec {'init_db':
#    command  => 'ckan db init',
#    path     => '/usr/bin',
#    require  => Service['jetty'],
#    #require => [Postgresql::Server::Db['ckan_default'],
#    #Service['jetty']],
#    returns => [0,1,2],
#  }

  # initialize db
  check_run::task { 'init_db':
    exec_command  => '/usr/bin/ckan db init',
    require  => Service['jetty'],
  } ->
  # setup permissions on the database
  check_run::task { 'set_database_perms':
    exec_command => '/usr/bin/python /usr/lib/ckan/default/src/ckan/ckanext/datastore/bin/datastore_setup.py ckan_default datastore_default ckan_default ckan_default datastore_default -p postgres',
    require => Check_run::Task['init_db'],
  }

  # only used when upgrading package to ensure a fresh backup
#  exec {'ckan_backup_oneoff':
#    command => '/usr/local/bin/ckan_backup.bash',
#    user    => backup,
#  }
  # set cron job for backing up ckan database
  cron {'ckan_backup':
    command => '/usr/local/bin/ckan_backup.bash',
    user    => backup,
    minute  => '0',
    hour    => '5',
    weekday => '7',
  }

  # set database privs
#  exec { 'db_privs' :
#    command => '/usr/bin/python datastore_setup.py ckan_default datastore_default ckan_default ckan_default datastore_default -p postgres',
#    cwd     => '/usr/lib/ckan/default/src/ckan/ckanext/datastore/bin',
#    require => Postgresql::Server::Role['datastore_default'],
#  }

#  exec { 'compile-less-css':
#    command   => '/usr/lib/ckan/default/src/ckan/bin/less --production',
#    cwd       => '/usr/lib/ckan/default/src/ckan',
#    #subscribe => File[$homepage],
#    #notify    => Class['apache'],
#  }
}