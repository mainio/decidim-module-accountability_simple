# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ListImageUploader < ::Decidim::ImageUploader
      process resize_to_limit: [850, 320]

      def max_image_height_or_width
        8000
      end
    end
  end
end
