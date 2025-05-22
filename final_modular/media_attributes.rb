module AppName
  module Attributes
    class MediaAttributes < BaseAttribute
      def self.attributes_for(model)
        attachments = model.configuration&.fields&.attachments
        return [] unless attachments.present?

        single_media_attributes(attachments) + multiple_media_attributes(attachments)
      end

      private

      def self.single_media_attributes(attachments)
        build_media_attributes(attachments, 'single_media') do |name|
          { "#{name}_attachment_attributes".to_sym => media_permitted_attributes }
        end
      end

      def self.multiple_media_attributes(attachments)
        build_media_attributes(attachments, 'multiple_media') do |name|
          { "#{name}_attachments_attributes".to_sym => media_permitted_attributes }
        end
      end

      def self.build_media_attributes(attachments, type)
        attachments
          .where(field_type: type)
          .pluck(:name)
          .map { |name| yield(name) }
      end

      def self.media_permitted_attributes
        %i[file source id name]
      end
    end
  end
end