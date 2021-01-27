require 'google-cloud-tasks'
require 'net/http'

module RailsCloudTasks
  module AppEngine
    class << self
      def project_id
        @project_id ||= metadata('project/project-id')
      end

      def service_account_email
        @service_account_email ||= metadata('instance/service-accounts/default/email')
      end

      def reset!
        @project_id = nil
        @service_account_email = nil
      end

      protected

      def metadata(path)
        return nil unless ::Google::Auth::GCECredentials.on_gce?

        uri = URI("http://metadata.google.internal/computeMetadata/v1/#{path}")

        req = Net::HTTP::Get.new(uri)
        req['Metadata-Flavor'] = 'Google'

        Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }.body
      rescue Errno::EHOSTDOWN
        # This error occurs sporadically when trying to resolve the metadata endpoint
        # locally. It is unlikely to occur when running on GCE.
        nil
      end
    end
  end
end
