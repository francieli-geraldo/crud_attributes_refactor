module AppName
  module Attributes
    class DynamicAttributes < BaseAttribute
      def self.attributes_for(model)
        return [] unless model.configuration&.fields&.not_static.present?
        
        [dynamic_fields_attributes: model.configuration.fields.not_static.pluck(:name).map(&:to_sym)]
      end
    end
  end
end