module Smyte
  class Util
    class << self
      def label_interesting?(name, options)
        return true unless options
        return true unless options[:labels]
        return true if options[:labels].empty?

        pieces = name.split(":")

        options[:labels].each do |check|
          if check.is_a?(String)
            return true if name == check
            return true if pieces.last == check
          elsif check.is_a?(Regexp)
            return true if name =~ check
            return true if pieces.last =~ check
          end
        end

        return false
      end
    end
  end
end
