# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the Medium (:m) result card
    # for an instance of a Result
    class ResultMCell < Decidim::CardMCell
      include Decidim::SanitizeHelper
      include Decidim::TranslationsHelper
      include Decidim::TooltipHelper
      include ActiveSupport::NumberHelper

      delegate :start_date, :end_date, :progress, to: :model

      private

      def resource_path
        resource_locator(model).path
      end

      def has_image?
        model.list_image && model.list_image.url.present?
      end

      def resource_image_path
        return unless model.list_image

        model.list_image.url
      end

      def status_label
        return unless model.status

        style = nil
        if model.status.color
          # Get the color hex in order to decide whether to use white or black
          # foreground color for the text. In case the color is closer to fully
          # black color, we use white foreground color and vice versa.
          color_hex = model.status.color.gsub(/^#/, "").hex

          style = {
            "background-color": model.status.color,
            "color": color_hex < 0xFFFFFF / 2 ? "#fff" : "#000"
          }.map { |key, val| "#{key}:#{val}" }.join(";")
        end

        content_tag :span, class: "label", style: style do
          translated_attribute(model.status.name)
        end
      end

      def presenters_for_identities
        model.identities.map do |identity|
          if identity.is_a?(Decidim::Organization)
            "#{model.class.module_parent}::OfficialAuthorPresenter".constantize.new
          else
            presenter_class =
              if identity.is_a?(Decidim::User)
                Decidim::AccountabilitySimple::UserCardPresenter
              elsif identity.is_a?(Decidim::UserGroup)
                Decidim::AccountabilitySimple::UserGroupCardPresenter
              end
            present(identity, presenter_class: presenter_class)
          end
        end
      end

      def description
        summary = translated_attribute(model.summary)
        unless summary
          desc = strip_tags(translated_attribute(model.description))
          summary = truncate(desc, length: 100)
        end

        decidim_sanitize(translated_attribute(summary))
      end

      def display_progress?
        model.component.settings.display_progress_enabled? && model.progress.present?
      end

      def display_data?
        true
      end

      def display_percentage(number)
        return if number.blank?

        number_to_percentage(number, precision: 1, strip_insignificant_zeros: true, locale: I18n.locale)
      end

      def progress_text
        return if progress.blank?

        number_to_percentage(progress, precision: 1, strip_insignificant_zeros: true, locale: I18n.locale, format: "%n%")
      end

      def statuses
        []
      end

      def has_dates?
        start_date.present? && end_date.present?
      end
    end
  end
end
