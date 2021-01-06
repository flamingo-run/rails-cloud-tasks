require 'google-cloud-tasks'

module RailsCloudTasks
  class Job
    class << self
      def perform_now(params = nil)
        new.perform(params)
      end

      def perform_later(params = nil)
        enqueue_task(params)
      end

      def perform_in(interval, params = nil)
        timestamp = interval.from_now.to_i
        enqueue_task(params, timestamp)
      end

      def perform_at(datetime, params = nil)
        timestamp = datetime.to_i
        enqueue_task(params, timestamp)
      end

      private

      CONFIG = RailsCloudTasks.config
      QUEUE_ATTRS = {
        project:  CONFIG.project_id,
        location: CONFIG.location_id,
        queue:    CONFIG.queue_id
      }.freeze

      def enqueue_task(payload, timestamp = nil)
        queue_path = client.queue_path(QUEUE_ATTRS)

        response =
          begin
            client.create_task(parent: queue_path, task: create_task(payload, timestamp))
          rescue Google::Cloud::FailedPreconditionError
            client.create_queue(
              parent: queue_path.split('/queues').first,
              queue:  { name: queue_path }
            )

            retry
          end

        response.name
      end

      def create_task(payload, timestamp)
        {
          http_request:  {
            http_method: :POST,
            url:         "#{CONFIG.base_url}/cloud-tasks/#{name}",
            body:        payload.to_json
          },
          schedule_time: timestamp && Google::Protobuf::Timestamp.new.tap do |ts|
            ts.seconds = timestamp
          end
        }.compact
      end

      def client
        @client ||= Google::Cloud::Tasks.cloud_tasks
      end
    end

    def perform(_); end
  end
end
