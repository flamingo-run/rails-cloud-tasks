module RailsCloudTasks
  module Instrumentation
    class Default
      def transaction_name!(*opts); end

      def add_custom_attributes(custom_attributes); end
    end
  end
end
