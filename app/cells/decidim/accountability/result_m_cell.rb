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
        resource_locator(model).path + request_params_query(resource_utm_params)
      end

      def request_params_query(extra_params = {}, exclude_params = [])
        final_params = request_params(extra_params, exclude_params)
        return "" unless final_params.any?

        "?#{final_params.to_query}"
      end

      def request_params(extra_params = {}, exclude_params = [])
        request.params.except(
          *(exclude_params + [
            :action,
            :component_id,
            :controller,
            :assembly_slug,
            :participatory_process_slug,
            :id
          ])
        ).merge(extra_params)
      end

      def resource_utm_params
        return {} unless context[:utm_params]

        context[:utm_params].transform_keys do |key|
          "utm_#{key}"
        end
      end

      def render_column?
        !context[:no_column].presence
      end

      def has_image?
        model.list_image && model.list_image.attached?
      end

      def has_category?
        model.category.present?
      end

      def resource_image_path
        return unless has_image?

        model.attached_uploader(:list_image).path
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
            color: color_hex < 0xFFFFFF / 2 ? "#fff" : "#000"
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
              case identity
              when Decidim::User
                Decidim::AccountabilitySimple::UserCardPresenter
              when Decidim::UserGroup
                Decidim::AccountabilitySimple::UserGroupCardPresenter
              end
            present(identity, presenter_class: presenter_class)
          end
        end
      end

      def description
        summary = translated_attribute(model.summary)
        if summary.blank?
          desc = translated_attribute(model.description)
          doc = Nokogiri::HTML(desc)
          doc.css("h1, h2, h3, h4, h5, h6").remove
          summary = truncate(strip_tags(doc.at("body")&.inner_html), length: 100)
        end

        decidim_sanitize(translated_attribute(summary))
      end

      # Generates a project summary either based on the translated summary field
      # or when that is empty, by stripping the relevant parts from the project
      # description and truncating that to the defined length.
      #
      # The result is a plain text string without any HTML markup.
      #
      # Returns a String.
      def project_summary_for(project)
        text = translated_attribute(project.summary)
        return decidim_sanitize(text) if text.present?

        # Strip the headings off the description text
        text = translated_attribute(project.description)
        doc = Nokogiri::HTML(text)
        doc.css("h1, h2, h3, h4, h5, h6").remove

        truncate(strip_tags(doc.at("body")&.inner_html), length: 100)
      end

      def display_progress?
        model.component.settings.display_progress_enabled? && model.progress.present?
      end

      def display_data?
        true
      end

      def show_favorite_button?
        !context[:disable_favorite].presence
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
        [:favoriting_count, :comments_count]
      end

      def favoriting_count_status
        cell("decidim/favorites/favoriting_count", model)
      end

      def has_dates?
        start_date.present? && end_date.present?
      end

      def category
        translated_attribute(model.category.name) if has_category?
      end

      def category_class
        "card__category--#{model.category.id}" if has_category?
      end

      def category_style
        cat = color_category
        return unless cat

        "background-color:#{cat.color};"
      end

      def category_icon
        cat = icon_category
        return unless cat

        full_category = []
        full_category << translated_attribute(cat.parent.name) if cat.parent
        full_category << translated_attribute(cat.name)

        content_tag(:span, class: "card__category__icon", "aria-hidden": true) do
          image_tag(cat.attached_uploader(:category_icon).path, alt: full_category.join(" - "))
        end
      end

      def icon_category(cat = nil)
        return unless has_category?

        cat ||= model.category
        return unless cat.respond_to?(:category_icon)
        return cat if cat.category_icon && cat.category_icon.attached?
        return unless cat.parent

        icon_category(cat.parent)
      end

      def color_category(cat = nil)
        return unless has_category?

        cat ||= model.category
        return unless cat.respond_to?(:color)
        return cat if cat.color
        return unless cat.parent

        color_category(cat.parent)
      end
    end
  end
end
