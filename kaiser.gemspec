
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kaiser/version'

Gem::Specification.new do |spec|
  spec.name          = 'kaiser'
  spec.version       = Kaiser::VERSION
  spec.authors       = ['David Siaw']
  spec.email         = ['dsiaw@degica.com']

  spec.summary       = 'Manage your monsters'
  spec.description   = 'Monster management system'
  spec.homepage      = 'https://kaiser.pages.labs.degica.com'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this section
  # to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://gems.labs.degica.com'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = Dir['LICENSE.md', 'README.md', 'lib/**/*', 'exe/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'optimist'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'aruba-rspec'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'factory_bot', '~> 4.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
