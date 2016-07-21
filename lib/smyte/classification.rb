module Smyte
  class Classification
    include ::Smyte::LabelReporter

    def self.allowed
      new('verdict' => "ALLOW", 'labels' => {})
    end

    attr_reader :response, :options

    def initialize(response, options={})
      @response = response
      @options  = options || {}
    end

    protected

    def parse_labels
      out = []
      labels = response["labels"] || {}
      labels.each do |name, attributes|
        next unless ::Smyte::Util.label_interesting?(name, options)
        out << Smyte::Classification::Label.new(name, attributes)
      end
      out
    end

    def parse_allow?
      response["verdict"] == "ALLOW"
    end

    class Label
      attr_reader :name, :response
      def initialize(name, response)
        @name = name
        @response = response
      end

      # returns :block, :review, :allow, :unknown
      def action
        @action ||= calculate_action
      end

      def experimental?
        !response["enabled"]
      end

      protected

      def calculate_action
        return :allow if response["verdict"] == "ALLOW"

        if response["verdict"] == "BLOCK"
          if experimental?
            return :review
          else
            return :block
          end
        end

        return :unknown
      end
    end
  end
end