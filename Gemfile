source :rubygems

source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake',          			 :require => false
  gem 'puppet-lint',             :require => false
  gem 'beaker',                  :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end