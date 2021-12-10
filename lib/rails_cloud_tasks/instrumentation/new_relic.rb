module RailsCloudTasks
  module Instrumentation
    class NewRelic
      def transaction_name!(opts)
        agent.set_transaction_name(*opts)
      end

      def add_custom_attributes(custom_attributes)
        agent.add_custom_attributes(custom_attributes)
      end

      def agent
        @agent ||= ::NewRelic::Agent
      end
    end
  end
end
