require_relative 'boot'

require 'rails'
require 'action_controller/railtie'

Bundler.require(*Rails.groups)
require 'rails-cloud-tasks'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails.version.to_f
    config.eager_load = false
  end
end
