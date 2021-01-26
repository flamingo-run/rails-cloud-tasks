lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_cloud_tasks/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails-cloud-tasks'
  spec.version       = RailsCloudTasks::VERSION
  spec.authors       = ['Guilherme Araújo']
  spec.email         = ['guilhermeama@gmail.com']

  spec.summary       = 'Rails Cloud Tasks'
  spec.description   = 'This gem is a wrapper on Google Cloud Tasks'
  spec.homepage      = 'http://github.com/flamingo-run/rails-cloud-tasks'
  spec.license       = 'Apache License 2.0'

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_dependency 'activesupport', '>= 4'
  spec.add_dependency 'google-cloud-tasks', '>= 2'
  spec.add_development_dependency 'rails', '>= 4'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
end
