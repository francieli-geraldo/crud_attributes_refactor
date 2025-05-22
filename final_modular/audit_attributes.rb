module AppName
  module Attributes
    class AuditAttributes < BaseAttribute
      def self.attributes_for(model)
        model.should_audit_justification? ? [:audit_comment] : []
      end
    end
  end
end