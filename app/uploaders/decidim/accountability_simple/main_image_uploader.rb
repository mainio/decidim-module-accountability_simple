# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class MainImageUploader < ::Decidim::ImageUploader
      process resize_to_limit: [2340, 1300]
    end
  end
end
