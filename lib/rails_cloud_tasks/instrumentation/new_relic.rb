module RailsCloudTasks
  module Instrumentation
    class NewRelic
      def transaction_name!(opts)
        agent.set_transaction_name(*opts)
      end

      def agent
        @agent ||= ::NewRelic::Agent
      end
    end
  end
end
