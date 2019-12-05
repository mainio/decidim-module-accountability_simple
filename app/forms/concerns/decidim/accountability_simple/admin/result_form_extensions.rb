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

          validates :main_image,
                    file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                    file_content_type: { allow: ["image/jpeg", "image/png"] }
          validates :list_image,
                    file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                    file_content_type: { allow: ["image/jpeg", "image/png"] }
        end
      end
    end
  end
end
