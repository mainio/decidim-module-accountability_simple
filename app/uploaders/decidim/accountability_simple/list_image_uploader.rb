# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ListImageUploader < ::Decidim::ImageUploader
      set_variants do
        {
          default: { resize_to_limit: [850, 320] }
        }
      end

      def max_image_height_or_width
        8000
      end
    end
  end
end
