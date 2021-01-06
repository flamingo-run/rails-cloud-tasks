module RailsCloudTasks
  class Engine < ::Rails::Engine
    isolate_namespace RailsCloudTasks

    config.before_initialize do
      Rails.application.routes.append do
        mount RailsCloudTasks::Engine, at: '/cloud-tasks'
      end
    end
  end
end
