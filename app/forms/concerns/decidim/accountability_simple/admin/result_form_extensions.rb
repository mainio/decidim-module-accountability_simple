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

          attribute :result_details, Array[ResultDetailsForm]

          validates :main_image,
                    file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                    file_content_type: { allow: ["image/jpeg", "image/png"] }
          validates :list_image,
                    file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                    file_content_type: { allow: ["image/jpeg", "image/png"] }
        end

        def map_model(model)
          self.result_details = model.result_details.first_class.map do |result_detail|
            ResultDetailsForm.from_model(result_detail)
          end
        end
      end
    end
  end
end
