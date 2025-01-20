# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module TagsHelper
      def sanitize_block(&block)
        decidim_sanitize(capture(&block))
      end
    end
  end
end
