# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      # This class holds a Form to update meeting agenda items
      class ResultDefaultDetailsForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :icon, String

        def to_param
          return id if id.present?

          "result-default-detail-item-id"
        end

        def map_model(model)
          # component = model.accountability_result_detailable
          # self.description = model.values.find_by(result: result).try(:description)
        end
      end
    end
  end
end
