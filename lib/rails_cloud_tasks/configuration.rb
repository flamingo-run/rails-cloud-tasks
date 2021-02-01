module RailsCloudTasks
  class Configuration
    attr_accessor :location_id, :host, :tasks_path, :service_account_email, :scheduler_file_path,
                  :scheduler_prefix_name

    attr_writer :project_id
    attr_reader :app_engine, :google_auth

    def initialize(app_engine = AppEngine, google_auth = Google::Auth)
      @service_account_email = ENV['GCP_SERVICE_ACCOUNT']
      @location_id = ENV['GCP_LOCATION']
      @project_id = ENV['GCP_PROJECT']
      @tasks_path = '/tasks'
      @scheduler_file_path = './config/scheduler.yml'
      @scheduler_prefix_name = 'rails-cloud'

      @app_engine = app_engine
      @google_auth = google_auth
    end

    def inject_routes
      tasks_path = @tasks_path

      Rails.application.routes.append do
        post "#{tasks_path}/:job_class", to: RailsCloudTasks::Rack::Jobs
        post tasks_path, to: RailsCloudTasks::Rack::Tasks
      end
    end

    def project_id
      @project_id ||= app_engine.project_id
    end

    def auth
      @auth ||= authenticate
    end

    private

    def authenticate
      email = service_account_email ||
              app_engine.service_account_email ||
              google_auth.get_application_default.issuer

      {
        oidc_token: {
          service_account_email: email
        }
      }
    end
  end
end
