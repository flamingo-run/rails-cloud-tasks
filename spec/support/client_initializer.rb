require 'rails-cloud-tasks'

RailsCloudTasks.configure do |config|
  config.project_id = 'test-project'
  config.location_id = 'us-central1'
  config.host = 'https://test.com'
  config.tasks_path = '/test-tasks'
  config.service_account_email = 'test@email.rails.cloud'
  config.scheduler_file_path = './spec/fixtures/scheduler_job.yml'
  config.scheduler_prefix_name = 'testing-rails-cloud'
end
