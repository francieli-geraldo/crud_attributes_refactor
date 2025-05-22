module AppName
  module CrudAttributes
    extend ActiveSupport::Concern

    class_methods do
      def define_crud_attributes
        return unless valid_configuration?

        attributes = attribute_providers.flat_map { |provider| provider.attributes_for(self) }
        const_set('CRUD_ATTRIBUTES', attributes.compact)
      rescue ActiveRecord::NoDatabaseError
        return
      end

      private

      def attribute_providers
        AppName::Attributes::BaseAttribute.descendants
      end

      def valid_configuration?
        table_exists? && configuration.present?
      end
    end
  end
end