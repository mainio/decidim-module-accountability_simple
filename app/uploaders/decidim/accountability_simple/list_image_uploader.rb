# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ListImageUploader < ::Decidim::ImageUploader
      set_variants do
        {
          default: { resize_to_limit: [860, 395] },
          box: { resize_to_fill: [660, 450] }
        }
      end

      def max_image_height_or_width
        8000
      end
    end
  end
end
