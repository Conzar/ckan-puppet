# installs the ckanext-spatial extension
class ckan::ext::spatial {

  $ckanext_spatial_libs = [
    'python-dev',
    'libxml2-dev',
    'libxslt1-dev',
    'libgeos-c1',
  ]

  class { 'postgresql::server::postgis': }

  package { $ckanext_spatial_libs:
    ensure => present,
  }

  ckan::ext { 'spatial':
    require => [Class['postgresql::server::postgis'], Package[$ckanext_spatial_libs]],
  }

  $sql_functions = '/usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql'
  $sql_tables = '/usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql'

  # Both of these SQL scripts are idempotent, so running them multiple times is
  # just fine.
  postgresql_psql { 'create postgis functions':
    command => "\\i $sql_functions",
    db      => 'ckan_default',
    require => Class['postgresql::server::postgis'],
  }

  postgresql_psql { 'create spatial tables':
    command => "\\i $sql_tables",
    db      => 'ckan_default',
    require => Class['postgresql::server::postgis'],
  }

  postgresql_psql { 'set spatial_ref_sys owner':
    command => "ALTER TABLE spatial_ref_sys OWNER TO ckan_default",
    db      => 'ckan_default',
    require => Postgresql_psql['create spatial tables'],
  }

  postgresql_psql { 'set geometry_columns owner':
    command => "ALTER TABLE geometry_columns OWNER TO ckan_default",
    db      => 'ckan_default',
    require => Postgresql_psql['create spatial tables'],
  }

}
