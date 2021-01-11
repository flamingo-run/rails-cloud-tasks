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
  config.project_id = 'my-gcp-project'
  config.location_id = 'us-central1'
  config.queue_id = 'my-queue'
  config.rate_limits = {
    max_concurrent_dispatches: 20,
    max_dispatches_per_second: 4.5
  }
  config.retry_config = {
    max_attempts: 10,
    max_doublings: 2
  }

  # Base url used by Cloud Tasks to reach your application and run the tasks
  config.base_url = 'https://myapplication.host.com'

  # Register a list of Job classes
  config.register_jobs([MyFirstJob, MySecondJob])
end
```

- Add a Job class:
```ruby
# ./app/jobs/my_first_job.rb

class MyFirstJob
  include RailsCloudTasks::Job

  # Here you may set queue settings on a per-job basis
  project_id 'some-other-project'
  queue_id 'some-other-queue'
  retry_config = max_attempts: 3

  def perform(attrs)
    # Execute stuff
  end
end
```

- Enqueue a job:
```ruby
# Use one of these methods to enqueue a job
MyJob.perform_later(attrs)
MyJob.perform_in(5.minutes, attrs)
MyJob.perform_at(2.hours.from_now, attrs)
```
## Tests

To run tests:

```
bundle exec rspec
```


## Version

Use [Semantic versioning](https://semver.org/).
