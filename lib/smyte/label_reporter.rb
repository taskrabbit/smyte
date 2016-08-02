module Smyte
  module LabelReporter
    # class needs to define parse_labels and parse_allow?
    # which returns objects that have an action

    # returns :block, :review, :allow, :unknown
    def action
      @action ||= calculate_action
    end

    def labels
      @labels ||= parse_labels
    end

    def label_actions
      return @label_actions if @label_actions
      found = Hash.new { |hash, key| hash[key] = [] }
      labels.each do |label|
        found[label.action] << label
      end

      @label_actions = found
    end

    def label_report
      return @label_report if @label_report
      out = []

      labels.each do |label|
        case label.action
        when :block, :review
          out << label.name
        end
      end

      @label_report = out
    end

    def reset_labels
      remove_instance_variable(:@label_report)  if defined?(@label_report)
      remove_instance_variable(:@label_actions) if defined?(@label_actions)
      remove_instance_variable(:@labels)        if defined?(@labels)
      remove_instance_variable(:@action)        if defined?(@action)
    end

    protected

    def calculate_action
      if label_actions[:block].size > 0
        return :block
      elsif label_actions[:review].size > 0
        return :review
      else
        return :allow
      end
    end
  end
end
