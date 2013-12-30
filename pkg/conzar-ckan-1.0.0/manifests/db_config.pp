# configuration supporting database for ckan
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
class ckan::db_config {

  # === configure postgresql ===
  # create the database
  # also create the user/password to access the db
  # user gets all privs by default
  postgresql::server::db {'ckan_default':
    user     => 'ckan_default',
    password => 'pass',
  }
  # create a seperate db for the datastore extension
  postgresql::server::db { 'datastore_default' :
    user     => 'ckan_default',
    password => 'pass',
  }
  # create a ro user for datastore extension
  postgresql::server::role { 'datastore_default' :
    password_hash => 'pass',
  }
  # grant privs for datastore user
  postgresql::server::database_grant { 'datastore_default' :
    privilege => 'CONNECT',
    db        => 'datastore_default',
    role      => 'datastore_default',
    require   => [Postgresql::Server::Role['datastore_default'],
                  Postgresql::Server::Db['datastore_default']],
  }
#  postgresql::database_grant { 'SCHEMA' :
#    privilege => 'USAGE, SELECT',
#    db        => 'SCHEMA',
#    role      => 'datastore_default',
#    require   => Postgresql::Database_user['datastore_default'],
#  }
}
