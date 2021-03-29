module RailsCloudTasks
  class Scheduler
    delegate :project_id, :location_id, :host, :auth, :tasks_path,
             :scheduler_file_path, :scheduler_prefix_name,
             :service_account_email, to: 'RailsCloudTasks.config'

    attr_reader :credentials, :logger

    def initialize(
      credentials: RailsCloudTasks::Credentials.new,
      logger: RailsCloudTasks.logger
    )
      @credentials = credentials
      @logger = logger
    end

    # Create & Update scheduler job on Google Cloud
    # TODO: Support to delete scheduled jobs
    def upsert
      result = { success: [], failure: [] }
      scheduler_jobs.each do |job|
        upsert_job(job) ? (result[:success] << job[:name]) : (result[:failure] << job[:name])
      end
      log_output(result)
    end

    def client
      @client ||= Google::Cloud::Scheduler.cloud_scheduler.configure do |config|
        config.credentials = credentials.generate(service_account_email)
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
        name:        "#{location_path}/jobs/#{scheduler_prefix_name}--#{job[:name]}",
        schedule:    job[:schedule],
        description: job[:description],
        time_zone:   job[:time_zone],
        http_target: {
          uri:         "#{host}#{tasks_path}/#{job[:class_name]}",
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

    def log_output(result)
      parse_task_name = ->(task) { task.split("#{scheduler_prefix_name}--")[1] }
      success = result[:success].map(&parse_task_name)
      failure = result[:failure].map(&parse_task_name)

      if success.count.positive?
        log("Successfuly scheduled #{success.count} tasks", '- [✓] ',
            success)
      end

      log("Failed to schedule #{failure.count} tasks", '- [𐄂] ', failure) if failure.count.positive?
    end

    def log(desc, prefix, tasks)
      logger.info(desc)
      logger.info(prefix + tasks.join("\n #{prefix}"))
    end

    private

    def upsert_job(job)
      success = true
      begin
        client.create_job parent: location_path, job: job
      rescue Google::Cloud::AlreadyExistsError
        client.update_job job: job
      rescue StandardError => e
        logger.error(e)
        success = false
      end
      success
    end
  end
end
