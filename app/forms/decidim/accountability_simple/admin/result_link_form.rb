# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      # This class holds a Form to update result links
      class ResultLinkForm < Decidim::Form
        include TranslatableAttributes

        mimic :result_link

        translatable_attribute :label, String
        translatable_attribute :url, String

        attribute :collection_id, Integer
        attribute :position, Integer
        attribute :deleted, Boolean, default: false

        validates :label, translatable_presence: true, unless: :deleted
        validates :url, translatable_presence: true, unless: :deleted
        validates :position, numericality: { greater_than_or_equal_to: 0 }, unless: :deleted

        def map_model(model)
          self.collection_id = model.decidim_accountability_simple_result_link_collection_id
        end

        def to_param
          return id if id.present?

          "result-link-item-id"
        end
      end
    end
  end
end
