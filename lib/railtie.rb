require 'rails-cloud-tasks'
require 'rails'

module RailsCloudTasks
  class Railtie < Rails::Railtie
    railtie_name :rails_cloud_tasks

    rake_tasks do
      namespace :rails_cloud_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end
    end
  end
end
