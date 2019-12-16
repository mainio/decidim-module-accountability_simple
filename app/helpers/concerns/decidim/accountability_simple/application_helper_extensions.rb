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
    end
  end
end
