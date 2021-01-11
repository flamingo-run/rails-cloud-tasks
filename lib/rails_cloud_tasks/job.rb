require 'google-cloud-tasks'

module RailsCloudTasks
  module Job
    extend ActiveSupport::Concern

    def perform(_); end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def project_id(id)
        @project = id
      end

      def location_id(id)
        @location = id
      end

      def queue_id(id)
        @queue = id
      end

      def rate_limits(attrs)
        @rate_limits = attrs
      end

      def retry_config(attrs)
        @retry_config = attrs
      end

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

      CONFIG = RailsCloudTasks.config

      def queue_attrs
        {
          project:  @project || CONFIG.project_id,
          location: @location || CONFIG.location_id,
          queue:    @queue || CONFIG.queue_id
        }
      end

      private

      def enqueue_task(payload, timestamp = nil)
        queue_path = client.queue_path(queue_attrs)

        response =
          begin
            client.create_task(parent: queue_path, task: create_task(payload, timestamp))
          rescue Google::Cloud::FailedPreconditionError
            client.create_queue(create_queue(queue_path))

            retry
          end

        response.name
      end

      def create_queue(queue_path)
        {
          parent: queue_path.split('/queues').first,
          queue:  {
            name:         queue_path,
            rate_limits:  CONFIG.rate_limits&.merge(@rate_limits || {}),
            retry_config: CONFIG.retry_config&.merge(@retry_config || {})
          }.compact
        }
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
  end
end
