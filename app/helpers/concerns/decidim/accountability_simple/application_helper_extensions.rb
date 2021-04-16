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

      def result_progress_info(result)
        color = result.theme_color || default_theme_color
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
        color = result.theme_color || default_theme_color
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

        color_parent = result
        color_parent = color_parent.parent while color_parent.parent && color_parent.theme_color&.empty?

        color = color_parent.theme_color || default_theme_color
        style = "background-color: #{color};"

        content_tag(:span, "", class: "definition-data__icon__marker", style: style).html_safe
      end

      def default_theme_color
        "#abb2bd"
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
        accountability_icons ||= %w(calendar budget vote)
        return asset_path("decidim/accountability_simple/icons.svg") if accountability_icons.include?(name)

        # Decidim defaults
        asset_path("decidim/icons.svg")
      end
    end
  end
end
