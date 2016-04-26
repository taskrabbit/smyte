module Smyte
  class Config
    attr_accessor :logger
    attr_writer :api_key, :api_secret, :webhook_secret

    def api_key
      return @api_key if @api_key
      raise "Smyte api_key not set"
    end

    def api_secret
      return @api_secret if @api_secret
      raise "Smyte api_secret not set"
    end

    def webhook_secret
      return @webhook_secret if @webhook_secret
      raise "Smyte webhook_secret not set"
    end

    def enabled=input
      @enabled = !!(input.to_s =~ /^(t|1|y|ok)/)
    end

    def enabled
      return true if @enabled.nil?
      @enabled
    end

    def enabled?
      enabled
    end
  end
end
