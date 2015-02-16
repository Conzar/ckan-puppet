# == Class: ckan::ext::hierarchy
#
# Installs the "hierarchy" extension from data.gov.uk, which allows
# organisations to have parents, and displays them in a tree.
#
class ckan::ext::hierarchy {
  ckan::ext { 'hierarchy':
    source   => 'git://github.com/datagovuk/ckanext-hierarchy.git',
    revision => 'master',
    plugin   => 'hierarchy_form hierarchy_display'
  }
}