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
class ckan::ext::googleanalytics(
  $id       = undef,
  $account  = undef,
  $username = undef,
  $password = undef
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

  ckan::ext { 'googleanalytics': }

  concat::fragment { 'ckanext-googleanalytics':
    target  => '/etc/ckan/default/production.ini',
    content => "
# Google Analytics extension
googleanalytics.id = ${id}
googleanalytics.account = ${account}
googleanalytics.username = ${username}
googleanalytics.password = ${password}
",
  }
}
