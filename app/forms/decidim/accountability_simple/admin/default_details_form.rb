# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      # This class holds a Form to update meeting agenda items
      class DefaultDetailsForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String

        attribute :icon, String
        attribute :position, Integer
        attribute :deleted, Boolean, default: false

        validates :title, translatable_presence: true, unless: :deleted
        validates :position, numericality: { greater_than_or_equal_to: 0 }, unless: :deleted

        def to_param
          return id if id.present?

          "result-detail-item-id"
        end
      end
    end
  end
end
