Facter.add('ckan_production_plugins') do
  setcode 'cat /etc/ckan/plugins.out'
end