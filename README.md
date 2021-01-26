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
  config.project_id = 'my-gcp-project' # This is not needed if running on GCE
  config.location_id = 'us-central1'

  # Base url used by Cloud Tasks to reach your application and run the tasks
  config.host = 'https://myapplication.host.com'
  config.tasks_path = '/v2/tasks' # default: '/tasks'

  # Inject routes into application
  config.inject_routes
end
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
## Tests

To run tests:

```
bundle exec rspec
```


## Version

Use [Semantic versioning](https://semver.org/).
