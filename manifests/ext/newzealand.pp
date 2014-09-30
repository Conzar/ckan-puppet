# == Class: ckan::ext::newzealand
#
# Installs the "newzealand landcare" extension
#
# You should enable the "newzealand_landcare" plugin once the 
# extension is installed.
#
class ckan::ext::newzealand {
  ckan::ext { 'newzealand':
    source   => 'git://github.com/okfn/ckanext-newzealand_landcare.git',
    revision => 'master',
  }
}
