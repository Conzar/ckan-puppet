# == Class: ckan::ext::newzealand
#
# Installs the "newzealand landcare" extension
#
class ckan::ext::newzealand {
  ckan::ext { 'newzealand':
    source   => 'git://github.com/okfn/ckanext-newzealand_landcare.git',
    revision => 'master',
    plugin   => 'newzealand_landcare',
  }
}