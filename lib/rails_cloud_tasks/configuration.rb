module RailsCloudTasks
  class Configuration
    attr_accessor :project_id, :location_id, :host, :tasks_path, :jobs, :auth

    def initialize
      @jobs = Set.new
      @project_id = AppEngine.project_id
      @tasks_path = '/tasks'
      @auth = authenticate
    end

    def inject_routes
      tasks_path = @tasks_path

      Rails.application.routes.append do
        post "#{tasks_path}/:job_class", to: RailsCloudTasks::Rack::Jobs
        post tasks_path, to: RailsCloudTasks::Rack::Tasks
      end
    end

    private

    def authenticate
      email = AppEngine.service_account_email || Google::Auth.get_application_default.issuer

      {
        oidc_token: {
          service_account_email: email
        }
      }
    rescue RuntimeError, Errno::EHOSTDOWN
      # EHOSTDOWN occurs sporadically when trying to resolve the metadata endpoint
      # locally. It is unlikely to occur when running on GCE.
      {}
    end
  end
end
