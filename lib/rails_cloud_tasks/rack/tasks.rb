require 'json'
require 'rack'

module RailsCloudTasks
  module Rack
    class Tasks
      class << self
        def call(env)
          request = ::Rack::Request.new(env)
          job = extract_job(request)

          ActiveJob::Base.execute(job)

          response(200, {})
        rescue Rack::InvalidPayloadError => e
          response(400, { error: e.cause.message })
        rescue StandardError => e
          response(500, { error: e.message })
        end

        private

        def extract_job(request)
          body = request.body.read
          JSON.parse(body).fetch('job')
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
