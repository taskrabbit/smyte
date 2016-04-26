module Smyte
  class Notification
    def self.parse(webhook_secret, response)
      if webhook_secret != Smyte.webhook_secret
        raise "invalid webhook_secret: #{webhook_secret}"
      end
      Smyte::Notification.new(response)
    end

    attr_reader :response

    def initialize(response)
      @response = response
    end

    def items
      @items ||= parse_items
    end

    protected

    def parse_items
      out = {}
      items = response["items"] || []
      items.each do |hash|
        key = hash["item"]
        next unless key
        if out[key]
          out[key].send(:add_response, hash)
        else
          out[key] = Smyte::Notification::Item.new(hash)
        end
      end

      out.values
    end

    class Item
      include ::Smyte::LabelReporter

      attr_reader :responses

      def initialize(first_response)
        @responses = [first_response]
      end

      def key
        @item ||= responses.first["item"]
      end

      def type
        @type ||= key.split("/").first
      end

      def id
        @id ||= key.split("/").last
      end

      protected

      def add_response(response)
        reset_labels
        responses << response
        responses
      end

      def parse_labels
        out = []
        responses.each do |hash|
          out << Smyte::Notification::Label.new(hash)
        end
        out
      end
    end

    class Label
      attr_reader :name, :response
      def initialize(response)
        @name = response["labelName"]
        @response = response
      end

      # returns :block, :review, :allow, :unknown
      def action
        @action ||= calculate_action
      end

      def experimental?
        response["labelType"] == "PENDING"
      end

      protected

      def calculate_action
        case response["labelType"]
        when "ALLOW"
          return :allow
        when "PENDING"
          return :review
        when "ADDED", "BLOCK"
          return :block
        else
          return :unknown
        end
      end
    end

  end
end
