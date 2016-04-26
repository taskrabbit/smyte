require 'smyte'
require 'vcr'
require 'byebug'

alias byebug debugger

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock # or :fakeweb
end

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = :should
  end
  config.expect_with :rspec do |c|
    c.syntax = :should
  end

  config.after(:each) do
    Smyte.send(:reset)
  end
end
