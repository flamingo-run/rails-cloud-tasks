require 'bundler/setup'

require 'pry'
require 'rspec/its'
require 'shoulda-matchers'
require 'simplecov'
require 'simplecov_json_formatter'
require 'webmock/rspec'

require 'rails-cloud-tasks'

Dir[File.expand_path(File.join('spec/support/**/*.rb'))].sort.each { |f| require f }

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)

if ENV['COVERAGE']
  SimpleCov.start do
    add_filter '/spec/'
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RailsCloudTasks.configure do |config|
  config.project_id = 'test-project'
  config.location_id = 'us-central1'
  config.host = 'https://test.com'
  config.tasks_path = '/test-tasks'
  config.service_account_email = 'test@email.rails.cloud'
  config.scheduler_file_path = './spec/fixtures/scheduler_job.yml'
  config.scheduler_prefix_name = 'testing-rails-cloud'
  config.default_queue_name = 'my-app'
end
