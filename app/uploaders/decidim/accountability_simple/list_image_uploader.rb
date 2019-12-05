# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ListImageUploader < ::Decidim::ImageUploader
      process resize_to_limit: [850, 320]
    end
  end
end
