# frozen_string_literal: true

module AppName
  module CrudAttributes
    extend ActiveSupport::Concern

    class_methods do
      def define_crud_attributes
        return unless table_exists?
        return unless configuration

        fields = configuration&.fields&.not_static&.pluck(:name)&.map(&:to_sym)
        model_attributes = column_names.map(&:to_sym) - AppName.crud_blocklist_attrs

        fields_attachments = configuration&.fields&.attachments

        single_media_attachments = fields_attachments&.where(field_type: 'single_media')&.pluck(:name)&.map do |name|
          { "#{name}_attachment_attributes".to_sym => %i[file source id name] }
        end

        multiple_media_attachments = fields_attachments&.where(field_type: 'multiple_media')&.pluck(:name)&.map do |name|
          { "#{name}_attachments_attributes".to_sym => %i[file source id name] }
        end

        crud_attrs = model_attributes
        crud_attrs += [dynamic_fields_attributes: fields] if fields
        crud_attrs += single_media_attachments if single_media_attachments.present?
        crud_attrs += multiple_media_attachments if multiple_media_attachments.present?
        crud_attrs += [:audit_comment] if should_audit_justification?

        const_set('CRUD_ATTRIBUTES', crud_attrs)
      rescue ActiveRecord::NoDatabaseError
        return
      end
    end
  end
end
