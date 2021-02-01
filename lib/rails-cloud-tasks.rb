require_relative './railtie'

require 'active_support'
require 'rails_cloud_tasks/rack/errors'


module RailsCloudTasks

  extend ActiveSupport::Autoload

  autoload :Scheduler
  autoload :Adapter
  autoload :AppEngine
  autoload :Configuration
  autoload :Version

  module Rack
    extend ActiveSupport::Autoload

    autoload :Jobs
    autoload :Tasks
  end

  attr_writer :config

  def self.configure
    yield(config)
  end

  def self.config
    @config ||= Configuration.new
  end
end
