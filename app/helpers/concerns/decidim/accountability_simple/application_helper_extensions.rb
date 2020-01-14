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
        style = nil
        title_style = nil
        if result.theme_color
          style = "border-color: #{result.theme_color};"
          title_style = "background-color: #{result.theme_color};"
        end

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

        style = nil
        style = "background-color: #{result.theme_color};" if result.theme_color

        content_tag(:span, "", class: "definition-data__icon__marker", style: style).html_safe
      end
    end
  end
end
