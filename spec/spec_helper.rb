require 'bundler/setup'

require 'pry'
require 'rspec/its'
require 'shoulda-matchers'
require 'webmock/rspec'

Dir[File.expand_path(File.join('spec/support/**/*.rb'))].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
