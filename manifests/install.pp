# installs ckan
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
class ckan::install {
  # install apache required for ckan package
  class {'apache': 
    default_vhost => false,
    default_ssl_vhost => false,
  }
  apache::listen {'8080':}
  apache::listen {'443':}
  apache::listen {'8800':}
  
#sudo sh -c 'echo "NameVirtualHost *:8800" >> /etc/apache2/ports.conf'
#sudo sh -c 'echo "Listen 8800" >> /etc/apache2/ports.conf'

#    NameVirtualHost *:8080
#Listen 8080
#
#<IfModule mod_ssl.c>
#    Listen 443
#</IfModule>
#
#<IfModule mod_gnutls.c>
#    Listen 443
#</IfModule>
    

  class {'apache::mod::wsgi':}
  
  apache::vhost {'ndefault':
    servername => 'localhost',
    ip         => '*',
    port       => '80',
    serveradmin => $ckan::serveradmin,
    docroot     => '/var/www', 
    default_vhost => true,
    add_listen => false,

    directories => [
      { path => '/', 
        options => ['FollowSymLinks'], 
        allow_override => ['None'],
        headers => $ckan::apache_headers,
      },
      { path=> '/var/www', 
        options => ['Indexes','FollowSymLinks','MultiViews'], 
        allow_override => ['None'],
        order => 'Allow,Deny',
        allow => 'from all',
        headers => $ckan::apache_headers,
      },
      { path => '/usr/lib/cgi-bin',
        allow_override => ['None'],
        options => ['+ExecCGI','-MultiViews','+SymLinksIfOwnerMatch'],
        order => 'Allow,Deny',
        allow => 'from all',
        headers => $ckan::apache_headers,
      },
      {
        path => '/usr/share/doc',
        options => ['Indexes','MultiViews','FollowSymLinks'],
        allow_override => ['None'],
        order => 'Deny,Allow',
        deny => 'from all',
        allow => 'from 127.0.0.0/255.0.0.0 ::1/128',
        headers => $ckan::apache_headers,
      }
    ],

    scriptaliases => [
      {
        alias => '/cgi-bin',
        path => '/usr/lib/cgi-bin'
      }
    ],

    aliases => [
      {
        alias => '/doc/',
        path  => '/usr/share/doc/',
      }
    ],

    error_log_file => 'error.log',
    log_level => 'warn',
  }
  
  apache::vhost { 'ndefault-ssl':
    serveradmin => $ckan::serveradmin,
    port    => '443',
    docroot => '/var/www',
    ssl     => true,
    add_listen => false,
    directories => [
      {
        path => '/',
        options => ['FollowSymLinks'],
        allow_override => ['None'],
        headers => $ckan::apache_headers,
      },
      {
        path => '/var/www',
        options => ['Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['None'],
        order => 'Allow,deny',
        allow => 'from all',
        headers => $ckan::apache_headers,
      },
      {
        path => '/usr/lib/cgi-bin',
        allow_override => ['None'],
        options => ['+ExecCGI','-MultiViews','+SymLinksIfOwnerMatch'],
        order => 'Allow,Deny',
        allow => 'from all',
        headers => $ckan::apache_headers,
      },
      {
        path => '/usr/share/doc',
        options => ['Indexes','MultiViews','FollowSymLinks'],
        allow_override => ['None'],
        order => 'Deny,Allow',
        deny => 'from all',
        allow => 'from 127.0.0.0/255.0.0.0 ::1/128',
        headers => $ckan::apache_headers,
      },
      {
        path => '/usr/lib/cgi-bin',
        ssl_options => ['+StdEnvVars'],
        headers => $ckan::apache_headers,
      },
      {
        path => '\.(cgi|shtml|phtml|php)$',
        provider => 'files',
        ssl_options => ['+StdEnvVars'],
        headers => $ckan::apache_headers,
      }
    ],

    scriptaliases => [
      {
        alias => '/cgi-bin',
        path => '/usr/lib/cgi-bin'
      }
    ],

    aliases => [
      {
        alias => '/doc/',
        path  => '/usr/share/doc/',
      }
    ],

    ssl_cert  => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    ssl_key   => '/etc/ssl/private/ssl-cert-snakeoil.key',

    error_log_file => 'error.log',
    log_level => 'warn',
    

#        BrowserMatch "MSIE [2-6]" \
#                nokeepalive ssl-unclean-shutdown \
#                downgrade-1.0 force-response-1.0
#        BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
  }

# for the ckan site
  apache::vhost { 'ckan_default':
    docroot                     => '/var/www', # note, this is overwritten b/c of wsgi but is required by this defined type
    ip                          => '0.0.0.0',
    port                        => '8080',
    servername                  => 'default.ckanhosted.com',
    serveraliases               => 'www.default.ckanhosted.com',
    add_listen => false,
    wsgi_script_aliases           => {'/' => '/etc/ckan/default/apache.wsgi'},
    wsgi_pass_authorization     => 'On',
    wsgi_daemon_process         => 'ckan_default', 
    wsgi_daemon_process_options => { processes => '2', threads => '15', display-name => 'ckan_default' },
    wsgi_process_group          => 'ckan_default',
    headers => $ckan::apache_headers,
  }

  # for the datapusher
  apache::vhost { 'datapusher':
    docroot                     => '/var/www', # note, this is overwritten b/c of wsgi but is required by this defined type
    ip                          => '0.0.0.0',
    port                        => '8800',
    servername                  => 'ckan',
    add_listen => false,
    wsgi_script_aliases         => {'/' => '/etc/ckan/datapusher.wsgi'},
    wsgi_daemon_process         => 'datapusher', 
    wsgi_daemon_process_options => { processes => '1', threads => '15', display-name => 'demo' },
    wsgi_process_group          => 'datapusher',
    wsgi_pass_authorization     => 'On',
    headers => $ckan::apache_headers,
  }

  ## require supporting libs
  $ckan_libs = ['nginx','libpq5','python-pastescript']
  package { $ckan_libs:
    ensure => present,
  }
  # uses the preconfigured ubuntu repo
  if $ckan::is_ckan_from_repo == true {
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
  class { 'postgresql::server':
    pg_hba_conf_defaults => $ckan::pg_hba_conf_defaults,
    postgres_password => $ckan::postgres_pass,
    listen_addresses => '*',
  }

  # === utility packages ===
  # need the latest version of nodejs in order to use
  # the ckan script bin/less
#  package { ['nodejs'] :
#    ensure  => present,
#  }
  include nodejs

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
