# == Class ckan::postinstall
#
# Manages services for ckan
#
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
class ckan::service {

  # update the plugin configuration
  # must run every run
  exec {'update_plugins':
    command     => "/opt/ckan_plugin_collector/plugin_collector.bash\
 /etc/ckan/plugins",
  }
  service { 'jetty':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Exec['update_plugins'],
  }
  service { 'apache2':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Service['jetty'],
  }
  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Service['apache2'],
  }
}