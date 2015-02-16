# == Class: ckan::ext::googleanalytics
#
# Installs the "googleanalytics" extension, which sends tracking data to Google
# Analytics and retrieves statistics from Google Analytics and inserts them into
# CKAN pages.
#
# You should enable the "googleanalytics" plugin to use this extension.
#
# === Parameters
#
# [*id*]
#   The Google Analytics tracking ID (usually of the form UA-XXXXXX-X).
#   Required.
#
# [*account*]
#   The account name (e.g. example.com -- see the top-level item at
#   https://www.google.com/analytics). Required.
#
# [*username*]
#   Google Analytics username. Required.
#
# [*password*]
#   Google Analytics password. Required.
#
# [*track_events*]
#   Adds Google Analystics Event tracking.
#   Default is false.
#
class ckan::ext::googleanalytics(
  $id       = undef,
  $account  = undef,
  $username = undef,
  $password = undef,
  $track_events = false
) {

  if $id == undef {
    fail('The id parameter to ckan::ext::googleanalytics is required')
  }
  if $account == undef {
    fail('The account parameter to ckan::ext::googleanalytics is required')
  }
  if $username == undef {
    fail('The username parameter to ckan::ext::googleanalytics is required')
  }
  if $password == undef {
    fail('The password parameter to ckan::ext::googleanalytics is required')
  }

  ckan::ext { 'googleanalytics':
    plugin => 'googleanalytics',
  }

  concat::fragment { 'ckanext-googleanalytics':
    target  => '/etc/ckan/default/production.ini',
    content => "
# Google Analytics extension
googleanalytics.id = ${id}
googleanalytics.account = ${account}
googleanalytics.username = ${username}
googleanalytics.password = ${password}
googleanalytics.track_events = ${track_events}
",
  }
  # setup cron job to push events
  if $track_events {
    # run the cron every hour
    cron {'analystics_push_events':
      command => "${ckan::config::paster} --plugin=ckan tracking update\
 -c ${ckan::config::ckan_conf} && ${ckan::config::paster} --plugin=ckan\
 search-index rebuild -r -c ${ckan::config::ckan_conf}",
      hour    => '*/1',
    }
  }
}