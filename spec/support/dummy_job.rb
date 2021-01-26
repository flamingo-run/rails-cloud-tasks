require 'active_job/railtie'

class DummyJob < ActiveJob::Base
  queue_as :dummy

  def perform(args); end
end
