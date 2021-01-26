require 'json'
require 'rack'

module RailsCloudTasks
  module Rack
    class Jobs
      class << self
        def call(env)
          job_class = extract_job_class(env)

          request = ::Rack::Request.new(env)
          job_args = extract_args(request)
          job_class.perform_now(job_args)

          response(200, { error: nil })
        rescue Rack::InvalidPayloadError => e
          response(422, { error: e.message })
        rescue StandardError => e
          response(500, { error: e.message })
        end

        private

        def extract_job_class(env)
          env.dig('action_dispatch.request.path_parameters', :job_class)
             .constantize
        end

        def extract_args(request)
          body = request.body.read
          JSON.parse(body)
        rescue JSON::ParserError, KeyError
          raise Rack::InvalidPayloadError
        end

        def response(status, body)
          [status, { 'Content-Type' => 'application/json' }, [body.to_json]]
        end
      end
    end
  end
end
