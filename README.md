![Github CI](https://github.com/flamingo-run/rails-cloud-tasks/workflows/Github%20CI/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/00d8532b0dd6a345474a/maintainability)](https://codeclimate.com/github/flamingo-run/rails-cloud-tasks/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/00d8532b0dd6a345474a/test_coverage)](https://codeclimate.com/github/flamingo-run/rails-cloud-tasks/test_coverage)
[![ruby](https://img.shields.io/badge/ruby-2.7-red.svg)]()

# Rails Cloud Tasks

## APIs

The following APIs must be enabled in your project(s):

- [Cloud Tasks API](https://console.cloud.google.com/marketplace/product/google/cloudtasks.googleapis.com)
- [Admin SDK API](https://console.cloud.google.com/marketplace/product/google/admin.googleapis.com)

## Setup

### As an application (when contributing)

- Install packages:

```
  bundle install
```

### As a package (when inside another application)

- Add the gem to application's Gemfile:
```
gem 'rails-cloud-tasks'
```

- Add an initializer:
```ruby
# ./config/initializers/rails_cloud_tasks.rb

require 'rails-cloud-tasks'

RailsCloudTasks.configure do |config|
  config.service_account_email = 'test-account@test-project.iam.gserviceaccount.com'
  config.project_id = 'my-gcp-project' # This is not needed if running on GCE
  config.location_id = 'us-central1'
  config.scheduler_file_path = './custom_path/scheduler_jobs.yml'
  config.scheduler_prefix_name = 'my-app-name'

  # Base url used by Cloud Tasks to reach your application and run the tasks
  config.host = 'https://myapplication.host.com'
  config.tasks_path = '/v2/tasks' # default: '/tasks'

  # Inject routes into application
  config.inject_routes
end
```

Check out the available configs and its usage description:

| attribute             	| description                                                                                                 	| env support         	| app engine fallback 	| default value            	|
|-----------------------	|-------------------------------------------------------------------------------------------------------------	|---------------------	|--------------------	|--------------------------	|
| service_account_email 	| The app service account email. It''s used to impersonate an user on schedule job                            	| GCP_SERVICE_ACCOUNT 	| ✓                  	|                          	|
| project_id            	| The Project ID                                                                                              	| GCP_PROJECT         	| ✓                  	|                          	|
| location_id           	| The region where you app is running (eg: us-central1, us-east1...)                                          	| GCP_LOCATION        	| ✓                  	|                          	|
| host                  	| The app endpoint which the app is running. *Do not use custom domain* Use the generated domain by Cloud Run 	| GCP_APP_ENDPOINT    	|                    	|                          	|
| scheduler_file_path   	| Path which the scheduler file is located                                                                    	| 𐄂                   	|                    	| './config/scheduler.yml' 	|
| scheduler_prefix_name 	| The prefix to be set into scheduler job name                                                                	| 𐄂                   	|                    	| 'rails-cloud'            	|
| tasks_path            	| The path to run tasks                                                                                       	| 𐄂                   	|                    	| '/tasks'                 	|


- Configure ActiveJob queue_adapter

```ruby
# ./config/application.rb

config.active_job.queue_adapter = RailsCloudTasks.queue_adapter
```

- Add a Job class:
```ruby
# ./app/jobs/application_job.rb

class ApplicationJob < ActiveJob::Base
  queue_as 'my-default-queue'
end


# ./app/jobs/my_first_job.rb

class MyFirstJob < ApplicationJob
  # Here you may override the queue, if needed
  queue_as 'some-other-queue'

  def perform(attrs)
    # Execute stuff
  end
end
```

- Enqueue a job:
```ruby
MyJob.perform_later(attrs)
```

### Scheduled Jobs

We have support to Google Cloud Schedule. It's based on Cloud tasks, the jobs are scheduled with HTTP Target. We do not support Pub/Sub or App Engine HTTP for now.

Check out the follow sample of config file:
```yaml
# config/scheduler.yml
- name: UsersSyncJob
  schedule: 0 8 * * *
  description: Sync user data
  time_zone: "America/Los_Angeles"
  class_name: Users::SyncJob
  args:
    - this_first: argument
      is_a: hash
    - - this second argument
      - is an array
    - this third argument is a string
```

| attribute   	| description                                                    	                                                   | required 	|
|-------------	|----------------------------------------------------------------------------------                                  |----------	|
| name        	| Any descriptive name, following [Tasks naming restrictions][1]                                                     | ✓        	|
| schedule    	| The frequency to run your job. It should be a unix-cron format 	                                                   | ✓        	|
| description 	| What this job does                                             	                                                   | ✓        	|
| time_zone   	| Choose which one timezone your job must run                    	                                                   | ✓        	|
| args        	| Arguments to the job execution. Important: if present, this must be an array of items. Check out the example above | 𐄂          |
| class_name    | The Job class name (including namespace)                                                                           | ✓        	|

[1]: https://cloud.google.com/tasks/docs/reference/rpc/google.cloud.tasks.v2



## Tests

To run tests:

```
bundle exec rspec
```


## Version

Use [Semantic versioning](https://semver.org/).
