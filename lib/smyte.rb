require "smyte/version"
require "forwardable"

module Smyte

  autoload :Classification, 'smyte/classification'
  autoload :Client,         'smyte/client'
  autoload :Config,         'smyte/config'
  autoload :LabelReporter,  'smyte/label_reporter'
  autoload :Notification,   'smyte/notification'
  autoload :Util,           'smyte/util'

  class << self
    extend Forwardable

    def_delegators :config, :logger=, :logger,
                            :enabled=, :enabled, :enabled?,
                            :api_key=, :api_key,
                            :api_secret=, :api_secret,
                            :webhook_secret=, :webhook_secret

    def_delegators :client, :action, :classify


    def webhook(secret, response, options={})
      ::Smyte::Notification.parse(secret, response, options)
    end

    protected

    def reset
      # used by tests
      @config = nil
    end

    def config
      @config ||= ::Smyte::Config.new
    end

    def client
      ::Smyte::Client.new
    end

  end

end
