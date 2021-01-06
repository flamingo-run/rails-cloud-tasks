RailsCloudTasks::Engine.routes.draw do
  post '/:job_name', to: 'jobs#perform'
end
