require 'rake'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

exclude_paths = [
  'spec/**/*',
  'pkg/**/*',
  'tests/**/*'
]

PuppetSyntax.exclude_paths = exclude_paths

PuppetLint::RakeTask.new :lint do |config|
    config.ignore_paths = exclude_paths
end


PuppetLint.configuration.fail_on_warnings
#PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.with_context = true
PuppetLint.configuration.relative = true

task :default => [:lint]
