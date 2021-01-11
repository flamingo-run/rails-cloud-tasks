module RailsCloudTasks
  class Configuration
    attr_accessor :project_id, :location_id, :queue_id, :base_url, :jobs,
                  :rate_limits, :retry_config

    def initialize
      @jobs = Set.new
    end

    def register_jobs(classes)
      @jobs += classes.map(&:name)
    end
  end
end
