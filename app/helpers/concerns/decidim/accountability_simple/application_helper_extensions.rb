# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module ApplicationHelperExtensions
      extend ActiveSupport::Concern

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
        return icon(detail.icon) if detail && !detail.icon.empty?

        color = result.theme_color || default_theme_color
        style = "background-color: #{color};"

        content_tag(:span, "", class: "definition-data__icon__marker", style: style).html_safe
      end

      def default_theme_color
        "#abb2bd"
      end
    end
  end
end
