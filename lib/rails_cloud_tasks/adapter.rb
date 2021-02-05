require 'google-cloud-tasks'

module RailsCloudTasks
  class Adapter
    attr_reader :client

    delegate :project_id, :location_id, :host, :tasks_path, :auth, to: 'RailsCloudTasks.config'

    def initialize(client = Google::Cloud::Tasks.cloud_tasks)
      @client = client
    end

    def enqueue(job, timestamp = nil)
      path = client.queue_path(project: project_id, location: location_id, queue: job.queue_name)
      task = build_task(job, timestamp)

      begin
        client.create_task(parent: path, task: task)
      rescue Google::Cloud::FailedPreconditionError => e
        raise e if e.details != 'Queue does not exist.'

        client.create_queue(build_queue(path))
        retry
      end
    end

    def enqueue_at(job, timestamp)
      enqueue(job, timestamp.to_i)
    end

    private

    def url
      "#{host}#{tasks_path}"
    end

    def build_task(job, timestamp)
      {
        http_request:  {
          http_method: :POST,
          url:         url,
          body:        { job: job.serialize }.to_json.force_encoding('ASCII-8BIT')
        }.merge(auth),
        schedule_time: timestamp && Google::Protobuf::Timestamp.new.tap do |ts|
          ts.seconds = timestamp
        end
      }.compact
    end

    def build_queue(path)
      {
        parent: path.split('/queues').first,
        queue:  { name: path }
      }
    end
  end
end
