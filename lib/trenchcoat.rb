# frozen_string_literal: true

require_relative "trenchcoat/version"
require "active_model"

module Trenchcoat
  # The concern to include in your ActiveModel class definition
  module Model
    extend ActiveSupport::Concern

    def fallback_to_model_values(model:, attributes:)
      attributes.each do |attribute|
        next if send(attribute)

        send(:"#{attribute}=", model.public_send(attribute))
      end
    end

    class_methods do
      def copy_attribute_definitions(model_class:, attributes:)
        columns = model_class.columns_hash.with_indifferent_access

        attributes.each do |attribute_name|
          column = columns.fetch(attribute_name)
          attribute column.name, column.type, default: column.default
        end
      end

      def quack_like(model_instance_attr:)
        delegate :model_name, :persisted?, :id, to: model_instance_attr
      end
    end
  end
end
