# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class MainImageUploader < ::Decidim::ImageUploader
      process resize_to_limit: [2340, 1300]

      def max_image_height_or_width
        8000
      end
    end
  end
end
