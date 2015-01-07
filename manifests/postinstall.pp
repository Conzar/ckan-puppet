# == Class ckan::postinstall
#
# Manages tasks to be performed after the initial install like
# initializing the database
#
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
#
class ckan::postinstall {
  include check_run

  check_run::task { 'init_db':
    exec_command => '/usr/bin/ckan db init',
  }

  check_run::task { 'set_database_perms':
    exec_command => "/usr/bin/python /usr/lib/ckan/default/src/ckan/ckanext/\
datastore/bin/datastore_setup.py ckan_default datastore_default ckan_default\
 ckan_default datastore_default -p postgres",
    require      => Check_run::Task['init_db'],
  }
}