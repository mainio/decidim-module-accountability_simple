# frozen_string_literal: true

module Decidim
  module Accountability
    # Exposes the result resource so users can view them
    class ResultsController < Decidim::Accountability::ApplicationController
      include FilterResource
      helper Decidim::WidgetUrlsHelper
      helper Decidim::TraceabilityHelper
      helper Decidim::Accountability::BreadcrumbHelper
      helper Decidim::TooltipHelper

      helper_method :results, :geocoded_results, :result, :geocoded_result, :show_map?, :first_class_categories, :count_calculator

      def show
        raise ActionController::RoutingError, "Not Found" if result.blank? || !can_show_result?
      end

      private

      def can_show_result?
        return true if current_user&.admin?

        result.published?
      end

      def results
        @results ||= begin
          orders = [Arel.sql("title->>'#{current_locale}'")]
          orders << Arel.sql("title->>'#{current_organization.default_locale}'") if current_organization.default_locale != current_locale

          parent_id = params[:parent_id].presence
          search.results.published.where(parent_id: parent_id).order(*orders).page(params[:page]).per(12)
        end
      end

      def geocoded_results
        @geocoded_results ||= search.results.geocoded_data
      end

      def geocoded_result
        @geocoded_result ||= Result.where(id: params[:id]).geocoded_data
      end

      def show_map?
        return false unless current_component.settings.geocoding_enabled

        @show_map ||=
          if action_name == "show"
            geocoded_result.any?
          else
            # Search through all the results so that we are not hiding the map
            # in case the current search parameters do not contain any results
            # but overall there are results. E.g. if the current filter is
            # filtering the results by text, we might hide the map even when
            # there are results available in the database.
            Result.where(
              component: current_component,
              parent_id: params[:parent_id].presence
            ).published.geocoded_data.any?
          end
      end

      def result
        @result ||= Result.includes(:timeline_entries).where(component: current_component).find(params[:id])
      end

      def search_klass
        ResultSearch
      end

      def default_filter_params
        {
          search_text: "",
          scope_id: "",
          category_id: ""
        }
      end

      def context_params
        { component: current_component, organization: current_organization }
      end

      def first_class_categories
        @first_class_categories ||= current_participatory_space.categories.first_class
      end

      def count_calculator(scope_id, category_id)
        Decidim::Accountability::ResultsCalculator.new(current_component, scope_id, category_id).count
      end
    end
  end
end
