require_relative './railtie'

require 'active_support'
require 'rails_cloud_tasks/rack/errors'

module RailsCloudTasks
  extend ActiveSupport::Autoload

  autoload :Scheduler
  autoload :Credentials
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

  def self.logger
    return @logger if @logger

    @logger ||= (Rails.logger || Logger.new($stdout)).tap do |logger|
      logger.formatter = proc do |severity, datetime, _progname, msg|
        "[#{datetime}] #{severity} [rails-cloud-tasks]: #{msg}\n"
      end
    end
  end
end
