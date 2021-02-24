module RailsCloudTasks
  module Instrumentation
    class Factory
      def self.agent_class
        return NewRelic if defined?(::NewRelic)

        Default
      end
    end
  end
end
