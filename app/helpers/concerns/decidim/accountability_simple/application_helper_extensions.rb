# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module ApplicationHelperExtensions
      extend ActiveSupport::Concern
      include Decidim::LayoutHelper

      included do
        def heading_parent_level_results(count)
          text = translated_attribute(component_settings.heading_parent_level_results).presence
          if text
            "#{text}: #{count}"
          else
            t("results.count.results_count", scope: "decidim.accountability", count: count)
          end
        end

        def heading_leaf_level_results(count)
          text = translated_attribute(component_settings.heading_leaf_level_results).presence
          if text
            "#{text}: #{count}"
          else
            t("results.count.results_count", scope: "decidim.accountability", count: count)
          end
        end
      end

      def filter_categories_values
        organization = current_component.participatory_space.organization

        sorted_main_categories = current_component.participatory_space.categories.first_class.includes(:subcategories).sort_by do |category|
          [category.weight, translated_attribute(category.name, organization)]
        end

        sorted_main_categories.map do |category|
          [translated_attribute(category.name, organization), category.id]
        end
      end

      def result_theme_color(result)
        return default_theme_color unless result.category.respond_to?(:color)

        if result.category.color.present?
          result.category.color
        elsif result.category.parent && result.category.parent.color.present?
          result.category.parent.color
        elsif result.parent
          result_theme_color(result.parent)
        else
          default_theme_color
        end
      end

      def result_progress_info(result)
        color = result_theme_color(result)
        style = "border-color: #{color};"
        title_style = "background-color: #{color};"

        content_tag :div, class: "progress-level section", style: style do
          title = content_tag :div, class: "definition-data__boxtitle", style: title_style do
            t("models.result.fields.progress", scope: "decidim.accountability")
          end
          body = content_tag :div, class: "progress-level-data" do
            yield
          end

          title + body
        end
      end

      def result_detail_info(result)
        color = result_theme_color(result)
        style = "border-color: #{color};"
        title_style = "background-color: #{color};"

        content_tag :div, class: "card extra line-stats line-stats-project", style: style do
          title = content_tag :div, class: "definition-data__boxtitle", style: title_style do
            t("results.result.project_info", scope: "decidim.accountability")
          end
          body = content_tag :div, class: "definition-data" do
            yield
          end

          title + body
        end
      end

      def result_detail_icon(result, detail = nil)
        return accountability_icon(detail.icon) if detail && !detail.icon.empty?

        color = result_theme_color(result)
        style = "background-color: #{color};"

        content_tag(:span, "", class: "definition-data__icon__marker", style: style).html_safe
      end

      def default_theme_color
        "#abb2bd"
      end

      def human_range_time(start_date, end_date)
        if start_date && end_date
          return human_range_time(start_date, nil) if start_date.year == end_date.year && start_date.month == end_date.month

          start_date_format =
            if start_date.year == end_date.year
              "%b"
            else
              "%b %Y"
            end

          "#{I18n.l(start_date, format: start_date_format)} - #{I18n.l(end_date, format: "%b %Y")}"
        elsif start_date
          I18n.l(start_date, format: "%b %Y")
        elsif end_date
          I18n.l(end_date, format: "%b %Y")
        end
      end

      # Outputs an SVG-based icon.
      #
      # name    - The String with the icon name.
      # options - The Hash options used to customize the icon (default {}):
      #             :width  - The Number of width in pixels (optional).
      #             :height - The Number of height in pixels (optional).
      #             :aria_label - The String to set as aria label (optional).
      #             :aria_hidden - The Truthy value to enable aria_hidden (optional).
      #             :role - The String to set as the role (optional).
      #             :class - The String to add as a CSS class (optional).
      #
      # Returns a String.
      def accountability_icon(name, options = {})
        html_properties = {}

        html_properties["width"] = options[:width]
        html_properties["height"] = options[:height]
        html_properties["aria-label"] = options[:aria_label]
        html_properties["role"] = options[:role]
        html_properties["aria-hidden"] = options[:aria_hidden]

        html_properties["class"] = (["icon--#{name}"] + _icon_classes(options)).join(" ")

        content_tag :svg, html_properties do
          content_tag :use, nil, "xlink:href" => "#{_icon_asset_path(name)}#icon-#{name}"
        end
      end

      def _icon_asset_path(name)
        return "" if Decidim.cors_enabled

        accountability_icons ||= %w(calendar budget vote)
        return asset_pack_path("media/images/decidim_accountability_simple.svg") if accountability_icons.include?(name)

        # Decidim defaults
        asset_pack_path("media/images/icons.svg")
      end
    end
  end
end
