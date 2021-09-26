require_relative 'lib/data_portal/version'

Gem::Specification.new do |spec|
  spec.name        = 'data_portal'
  spec.version     = DataPortal::VERSION
  spec.authors     = ['Ahmed El.Hussaini']
  spec.email       = ['328866+sandboxws@users.noreply.github.com']
  spec.homepage    = 'https://www.github.com/sandboxws/data_portal'
  spec.summary     = 'Clean separation between data access, domain logic, and the presentation layer'
  spec.description = 'Clean separation between data access, domain logic, and the presentation layer'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = "TODO: Put your gem's public repo URL here."
  # spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'awesome_print', '~> 1.9'
  spec.add_dependency 'rails', '~> 6.1.4', '>= 6.1.4.1'
  spec.add_development_dependency 'binding_of_caller'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-rails'
  spec.add_development_dependency 'rspec', '>= 3.10'
end
