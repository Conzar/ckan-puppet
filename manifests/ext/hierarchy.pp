# Install the ckanext-hierarchy extension
class ckan::ext::hierarchy {
  ckan::ext { 'hierarchy':
    source   => 'git://github.com/datagovuk/ckanext-hierarchy.git',
    revision => 'master',
  }
}
