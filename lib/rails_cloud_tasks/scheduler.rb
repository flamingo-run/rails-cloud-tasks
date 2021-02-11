module RailsCloudTasks
  class Scheduler
    delegate :project_id, :location_id, :host, :auth, :tasks_path,
             :scheduler_file_path, :scheduler_prefix_name,
             :service_account_email, to: 'RailsCloudTasks.config'

    attr_reader :client, :credentials

    def initialize(
      client: Google::Cloud::Scheduler.cloud_scheduler,
      credentials: RailsCloudTasks::Credentials.new
    )
      client.configure do |config|
        config.credentials = credentials.generate(service_account_email)
      end
      @client = client
    end

    # Create & Update scheduler job on Google Cloud
    # TODO: Support to delete scheduled jobs
    def upsert
      scheduler_jobs.each do |job|
        begin
          client.create_job parent: location_path, job: job
        rescue Google::Cloud::AlreadyExistsError
          client.update_job job: job
        end
      end
    end

    protected

    def location_path
      @location_path ||= client.location_path project: project_id, location: location_id
    end

    def scheduler_jobs
      parse_jobs_from_file.map(&method(:build_job))
    end

    def build_job(job)
      {
        name:        "#{location_path}/jobs/#{scheduler_prefix_name}__#{job[:name]}",
        schedule:    job[:schedule],
        description: job[:description],
        time_zone:   job[:time_zone],
        http_target: {
          uri:         "#{host}#{tasks_path}/#{job[:name]}",
          http_method: 'POST',
          body:        job[:args].to_json
        }.merge(auth)
      }
    end

    def parse_jobs_from_file
      settings = File.read(File.expand_path(scheduler_file_path))
      YAML.safe_load(ERB.new(settings).result).map(&:deep_symbolize_keys)
    rescue Errno::ENOENT
      []
    end
  end
end
