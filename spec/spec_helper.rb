require 'bundler/setup'

require File.expand_path('test_app/config/environment.rb', __dir__)

require 'pry'
require 'rspec/its'
require 'rspec/rails'
require 'shoulda-matchers'
require 'simplecov'

require 'rails-cloud-tasks'

formatters = [SimpleCov::Formatter::HTMLFormatter]

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)

if ENV['COVERAGE']
  SimpleCov.start do
    add_filter '/spec/'
  end
end

RSpec.configure do |config|
  config.include RailsCloudTasks::Engine.routes.url_helpers
  config.include Rails.application.routes.url_helpers

  config.infer_spec_type_from_file_location!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

DummyJob = Class.new do
  include RailsCloudTasks::Job

  rate_limits max_dispatches_per_second: 2.0
  retry_config max_attempts: 8

  def self.name
    'DummyJob'
  end
end

RailsCloudTasks.configure do |config|
  config.project_id = 'test-project'
  config.location_id = 'us-central1'
  config.queue_id = 'test-queue'
  config.base_url = 'https://test.com'

  config.register_jobs([DummyJob])
end
