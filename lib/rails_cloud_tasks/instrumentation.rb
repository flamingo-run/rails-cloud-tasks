module RailsCloudTasks
  module Instrumentation
    extend ActiveSupport::Autoload

    autoload :Default
    autoload :Factory
    autoload :NewRelic

    module_function

    def agent
      @agent ||= RailsCloudTasks::Instrumentation::Factory.agent_class.new
    end

    def transaction_name!(*opts)
      agent.transaction_name!(opts)
    end
  end
end
