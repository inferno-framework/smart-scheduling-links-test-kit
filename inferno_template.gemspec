Gem::Specification.new do |spec|
  spec.name          = 'smart_scheduling_links_test_kit'
  spec.version       = '0.0.1'
  spec.authors       = ['Inferno Team']
  spec.email         = ['inferno@groups.mitre.org']
  spec.date          = Time.now.utc.strftime('%Y-%m-%d')
  spec.summary       = 'SMART Scheduling Links Test Kit'
  spec.description   = 'SMART Scheduling Links Test Kit'
  spec.homepage      = 'https://github.com/inferno-framework/smart-scheduling-links-test-kit'
  spec.license       = 'Apache-2.0'
  spec.add_runtime_dependency 'inferno_core', '~> 0.4.4'
  spec.add_development_dependency 'database_cleaner-sequel', '~> 1.8'
  spec.add_development_dependency 'factory_bot', '~> 6.1'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'webmock', '~> 3.11'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.2')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/inferno-framework/smart-scheduling-links-test-kit'
  spec.files = [
    Dir['lib/**/*.rb'],
    Dir['lib/**/*.json'],
    'LICENSE'
  ].flatten

  spec.require_paths = ['lib']
end
