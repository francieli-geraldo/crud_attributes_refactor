## Context and Challenge

The original implementation of CRUD attributes management was contained in a single file that handled multiple responsibilities:
- Basic model attributes management
- Dynamic fields handling
- Media attachments (both single and multiple)
- Audit attributes

### Problem Points in Original Implementation

```ruby
// filepath: /crud_attributes_refactor/original/crud_attributes.rb
def define_crud_attributes
  return unless table_exists?
  return unless configuration

  fields = configuration&.fields&.not_static&.pluck(:name)&.map(&:to_sym)
  model_attributes = column_names.map(&:to_sym) - AppName.crud_blocklist_attrs
  
  # Media handling mixed with other concerns
  fields_attachments = configuration&.fields&.attachments
  single_media_attachments = fields_attachments&.where(field_type: 'single_media')...
  multiple_media_attachments = fields_attachments&.where(field_type: 'multiple_media')...

  # Complex attribute assembly
  crud_attrs = model_attributes
  crud_attrs += [dynamic_fields_attributes: fields] if fields
  crud_attrs += single_media_attachments if single_media_attachments.present?
  crud_attrs += multiple_media_attachments if multiple_media_attachments.present?
  crud_attrs += [:audit_comment] if should_audit_justification?
end
```

## The Refactoring Solution

### 1. Modular Architecture

Created a base class and specialized providers for each type of attribute:
- `BaseAttribute`: Abstract base class defining the interface
- `DynamicAttributes`: Handles dynamic fields
- `MediaAttributes`: Manages both single and multiple media attachments
- `AuditAttributes`: Controls audit-related attributes

### 2. Single Responsibility Principle

Each class now has a clear, focused responsibility:

```ruby
// Example of focused responsibility in MediaAttributes
module AppName
  module Attributes
    class MediaAttributes < BaseAttribute
      def self.attributes_for(model)
        attachments = model.configuration&.fields&.attachments
        return [] unless attachments.present?

        single_media_attributes(attachments) + multiple_media_attributes(attachments)
      end
    end
  end
end
```

### 3. Extension and Maintenance Benefits

- New attribute types can be added by creating new provider classes
- Each provider can be tested independently
- Changes to one type of attribute don't affect others
- Clear separation of concerns

### 4. Code Organization Improvements

The refactored version:
- Reduced cognitive load by separating concerns
- Improved testability
- Enhanced maintainability
- Made the code more modular and extensible

## Technical Decisions and Benefits

### 1. Base Class Pattern
Created `BaseAttribute` as an abstract base class:
```ruby
class BaseAttribute
  def self.attributes_for(model)
    raise NotImplementedError, "#{self.class} must implement the .attributes_for method"
  end
end
```
**Benefit**: Enforces a consistent interface across all attribute providers

### 2. Automatic Provider Discovery
```ruby
def attribute_providers
  AppName::Attributes::BaseAttribute.descendants
end
```
**Benefit**: New providers are automatically included without modifying existing code

### 3. Simplified Main Logic
```ruby
def define_crud_attributes
  return unless valid_configuration?

  attributes = attribute_providers.flat_map { |provider| provider.attributes_for(self) }
  const_set('CRUD_ATTRIBUTES', attributes.compact)
end
```
**Benefit**: Main method is now clear and focused on orchestration

## Results

1. **Maintainability**: Each attribute type is isolated in its own file
2. **Testability**: Each provider can be tested independently
3. **Extensibility**: New attribute types can be added without modifying existing code
4. **Readability**: Clear separation of concerns makes the code easier to understand
5. **Reusability**: Each provider can potentially be used in different contexts
