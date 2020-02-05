# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # Custom helpers, scoped to the accountability admin engine.
      #
      module ApplicationHelper
        def tabs_id_for_default_detail(default_detail)
          "default_detail_item_#{default_detail.to_param}"
        end

        def tabs_id_for_result_detail(result_detail)
          "result_detail_item_#{result_detail.to_param}"
        end

        def result_detail_icons
          [
            [
              t("map_marker", scope: "decidim.accountability_simple.models.result_detail.icons"),
              "map-marker"
            ],
            [
              t("person", scope: "decidim.accountability_simple.models.result_detail.icons"),
              "person"
            ],
            [
              t("budget", scope: "decidim.accountability_simple.models.result_detail.icons"),
              "budget"
            ],
            [
              t("calendar", scope: "decidim.accountability_simple.models.result_detail.icons"),
              "calendar"
            ],
            [
              t("vote", scope: "decidim.accountability_simple.models.result_detail.icons"),
              "vote"
            ]
          ]
        end
      end
    end
  end
end
