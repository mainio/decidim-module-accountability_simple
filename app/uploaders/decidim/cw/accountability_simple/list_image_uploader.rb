# frozen_string_literal: true

module Decidim::Cw
  module AccountabilitySimple
    class ListImageUploader < ::Decidim::Cw::ImageUploader
      process resize_to_limit: [860, 395]

      def max_image_height_or_width
        8000
      end
    end
  end
end
