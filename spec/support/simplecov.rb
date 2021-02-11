require 'simplecov'
require 'simplecov_json_formatter'

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)

if ENV['COVERAGE']
  SimpleCov.start do
    add_filter '/spec/'
  end
end
