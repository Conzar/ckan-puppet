Facter.add('ckan_production_plugins') do
  setcode do
  	if File.exist? '/etc/ckan/plugins.out'
  		Facter::Core::Execution.exec('cat /etc/ckan/plugins.out')
  	end
  end
end