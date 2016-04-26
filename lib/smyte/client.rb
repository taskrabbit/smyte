require 'faraday'
require 'json'
require 'logger'

module Smyte
  class Client
    attr_reader :api_key, :api_secret, :logger, :enabled

    def initialize(options=nil)
      options ||= {}
      [:api_key, :api_secret, :logger, :enabled].each do |key|
        if options.has_key?(key)
          value = options[key]
        else
          value = Smyte.send(key)
        end
        instance_variable_set("@#{key}", value)
      end
    end

    def action(event_name, payload)
      return true if !enabled

      process(event_name, payload, "/v2/action")
      true # any success is just true - nothing else to know
    end

    def classify(event_name, payload)
      return Smyte::Classification.allowed if !enabled

      response = process(event_name, payload, "/v2/action/classify")
      Smyte::Classification.new(response)
    end

    protected

    def connection
      return @connection if @connection
      options = {
        url: 'https://api.smyte.com',
        headers: {
          'Content-Type'  => 'application/json'
        }
      }
      @connection = Faraday.new(options) do |faraday|
        # faraday.response :logger                # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter
      end
      @connection.basic_auth(api_key, api_secret)
      @connection
    end

    def process(event_name, payload, path)
      payload ||= {}
      if payload.has_key?('name')
        payload['name'] = event_name
      else
        payload[:name] = event_name
      end

      response = connection.post do |req|
        req.url path
        req.body = payload.to_json
      end
      
      if response.success?
        return JSON.parse(response.body)
      else
        hash = JSON.parse(response.body) rescue nil
        error = "Smyte Error (#{response.status})"
        if hash && hash["message"]
          error << ": "
          error << hash["message"]
          error << "\n"
        end
        raise error
      end
    end
  end
end