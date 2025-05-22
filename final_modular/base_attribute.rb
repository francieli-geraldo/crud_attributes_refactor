module AppName
  module Attributes
    class BaseAttribute
      def self.attributes_for(model)
        raise NotImplementedError, "#{self.class} must implement the .attributes_for method"
      end
    end
  end
end