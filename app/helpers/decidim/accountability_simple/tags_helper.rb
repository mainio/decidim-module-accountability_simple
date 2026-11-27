# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module TagsHelper
      def sanitize_block(&)
        decidim_sanitize(capture(&))
      end
    end
  end
end
