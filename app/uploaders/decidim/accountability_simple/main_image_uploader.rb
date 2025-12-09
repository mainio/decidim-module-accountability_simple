# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class MainImageUploader < ::Decidim::ImageUploader
      set_variants do
        {
          default: { resize_to_limit: [2340, 1300] },
          thumbnail: { resize_to_fill: [860, 395], auto_orient: true },
          thumbnail_box: { resize_to_fill: [660, 450], auto_orient: true },
          big: { resize_to_limit: [nil, 1000], auto_orient: true },
          main: { resize_to_fill: [1500, 920], auto_orient: true }
        }
      end

      def max_image_height_or_width
        8000
      end
    end
  end
end
