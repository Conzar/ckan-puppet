# == Class: ckan::ext::datastorer
#
# Installs the ckan datastorer extension
#
# === Authors
#
# Michael Speth <spethm@landcareresearch.co.nz>
#
# === Copyright
# GPLv3
#
class ckan::ext::datastorer {
  include check_run

  # setup tasks
  $task_name        = 'install_datastorer'
  $command          = "$check_run::command_path $check_run::root_dir/$task_name"
  $install_command  = '/usr/local/bin/install_datastorer.bash'
  
  
  # used for installing the components of this extension
  file {$install_command: 
    ensure => file,
    mode   => '0755',
  }

  # task for installing this extension
  check_run::task{$task_name:
    exec_command => $install_command,
    require => File[$install_command],
  }
  
  # TODO add cronjob to run the datastore upload
  # https://github.com/ckan/ckanext-datastorer
}