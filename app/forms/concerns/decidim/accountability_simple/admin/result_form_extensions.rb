# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module ResultFormExtensions
        extend ActiveSupport::Concern

        included do
          attribute :main_image
          attribute :list_image
          attribute :remove_main_image
          attribute :remove_list_image
          attribute :theme_color, String, default: "#ffffff"
          attribute :use_default_details, ::Decidim::Form::Boolean, default: true

          attribute :result_default_details, Array[ResultDefaultDetailsForm]
          attribute :result_details, Array[ResultDetailsForm]

          validates :main_image, passthru: { to: Decidim::Accountability::Result }
          validates :list_image, passthru: { to: Decidim::Accountability::Result }

          alias_method :map_model_original, :map_model
          alias_method :organization, :current_organization

          def map_model(model)
            map_model_original(model)

            self.result_default_details = model.result_default_details.map do |default_detail|
              default_detail_form = ResultDefaultDetailsForm.from_model(default_detail)
              default_detail_form.description = default_detail.values.find_by(
                result: model
              ).try(:description)

              default_detail_form
            end
            self.result_details = model.result_details.map do |result_detail|
              ResultDetailsForm.from_model(result_detail)
            end
          end
        end
      end
    end
  end
end
