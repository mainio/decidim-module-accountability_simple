# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders a result with its L-size card.
    class ResultLCell < Decidim::CardLCell
      def has_scope?
        model.scope.present?
      end

      def has_category?
        model.category.present?
      end

      def card_classes
        classes = super
        classes = classes.split unless classes.is_a?(Array)
        (classes + ["card--full"]).join(" ")
      end

      private

      def resource_image_variant
        return :box if has_list_image?

        :thumbnail_box
      end

      def category_image_variant
        :card_box
      end

      def creation_date_status
        l(model.published_at.to_date, format: :decidim_short)
      end
    end
  end
end
