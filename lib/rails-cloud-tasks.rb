require 'active_support'

module RailsCloudTasks
  extend ActiveSupport::Autoload

  autoload :Configuration
  autoload :Engine
  autoload :Job
  autoload :Version

  attr_writer :config

  def self.configure
    yield(config)
  end

  def self.register_jobs
    yield(config)
  end

  def self.config
    @config ||= Configuration.new
  end
end

require 'rails_cloud_tasks/engine' if defined?(::Rails::Engine)
