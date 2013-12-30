# installs the ckanext-spatial extension
class ckan::ckanext::spatial {
  $sql_functions = '/usr/share/postgresql/9.1/contrib/postgis-2.0/postgis.sql'
  $sql_tables = '/usr/share/postgresql/9.1/contrib/postgis-2.0/spatial_ref_sys.sql'
  include apt
    $packages = ['python-dev','libxml2-dev','libxslt1-dev',
                'libgeos-c1', 'postgresql-9.1-postgis','git']
  package {$packages:
    ensure  => present,
  }
  #### huge note, need to check if functions exists
  exec { 'create_gis_functions':
    command => "/usr/bin/psql $sql_functions",
    cwd     => '/var/lib/postgresql',
    group   => 'postgres',
    user    => 'postgres',
    require => Package['postgresql-9.1-postgis'],
    returns => [0,1,2],
    #unless  => '/usr/bin/psql -l | /usr/bin/grep template_postgis | /usr/bin/wc -l'
  }
  exec { 'create_gis_tables':
    command => "/usr/bin/psql $sql_tables",
    cwd     => '/var/lib/postgresql',
    group   => 'postgres',
    user    => 'postgres',
    require => Package['postgresql-9.1-postgis'],
    returns => [0,1,2],
    #unless  => '/usr/bin/psql -l | /usr/bin/grep template_postgis | /usr/bin/wc -l'
  }

  exec { 'change_owner_tables':
    command => "/usr/bin/psql -c 'ALTER TABLE spatial_ref_sys OWNER TO ckan_default; ALTER TABLE geometry_columns OWNER TO ckan_default'",
    cwd     => '/var/lib/postgresql',
    group   => 'postgres',
    user    => 'postgres',
    require => Exec['create_gis_functions','create_gis_tables'],
    returns => [0,1,2],
    #unless  => '/usr/bin/psql -l | /usr/bin/grep template_postgis | /usr/bin/wc -l'
  }
  exec { 'test_setup':
    command => '/usr/bin/psql -d ckan_default -c "SELECT postgis_full_version()"',
    group   => 'postgres',
    user    => 'postgres',
  }
  exec { 'install_spatial' :
    command => '/usr/bin/pip install -e git+https://github.com/okfn/ckanext-spatial.git@stable#egg=ckanext-spatial',
    require => [Package['python-pip'],
                Exec['test_setup']],
  }
  exec { 'install_requirements' :
    command => '/usr/bin/pip install -r pip-requirements.txt',
    require => Exec['install_spatial'],
  }
}
