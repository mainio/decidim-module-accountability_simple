# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class MainImageUploader < ::Decidim::ImageUploader
      set_variants do
        {
          default: { resize_to_limit: [2340, 1300] }
        }
      end

      def max_image_height_or_width
        8000
      end
    end
  end
end
