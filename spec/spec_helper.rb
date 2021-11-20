require 'bundler/setup'
require 'awesome_print'
require 'binding_of_caller'
require 'pry-rails'
# require 'simplecov'
# require 'simplecov-console'

# SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
# SimpleCov.start do
#   add_group 'AwesomeExplain','lib/awesome_explain'
#   add_filter '/spec/'
# end

require 'data_portal'

# module Rails
#   class Application
#   end
# end

# module MyApp
#   class Application < Rails::Application
#   end
# end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
