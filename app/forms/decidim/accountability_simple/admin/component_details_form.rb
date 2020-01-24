# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      # This class holds a Form to update meeting agenda items
      class ComponentDetailsForm < Decidim::Form
        attribute :details, Array[DefaultDetailsForm]

        def to_param
          return id if id.present?

          "result-detail-item-id"
        end

        def map_model(model)
          self.details = Decidim::AccountabilitySimple::ResultDetail.where(
            accountability_result_detailable: model
          ).map do |detail|
            DefaultDetailsForm.from_model(detail)
          end
        end
      end
    end
  end
end
