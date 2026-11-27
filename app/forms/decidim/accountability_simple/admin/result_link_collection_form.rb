# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      # A form object to create or update attachment collections.
      class ResultLinkCollectionForm < Form
        include TranslatableAttributes

        mimic :result_link_collection

        attribute :key, String
        attribute :position, Integer, default: 0
        translatable_attribute :name, String

        validates :name, translatable_presence: true
        validates :decidim_accountability_result_id, presence: true

        def decidim_accountability_result_id
          context[:result]&.id
        end
      end
    end
  end
end
