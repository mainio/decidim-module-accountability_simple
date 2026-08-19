# frozen_string_literal: true

module Decidim
  module Accountability
    # Exposes the result resource so users can view them
    class ResultsController < Decidim::Accountability::ApplicationController
      include FilterResource
      include Decidim::Paginable
      include Decidim::AccountabilitySimple::Orderable

      helper Decidim::TraceabilityHelper
      helper Decidim::Accountability::BreadcrumbHelper
      helper Decidim::Accountability::CalculatorHelper
      helper Decidim::TooltipHelper

      helper_method :results, :geocoded_results, :result, :geocoded_result, :show_map?, :first_class_taxonomies, :count_calculator

      def show
        raise ActionController::RoutingError, "Not Found" if result.blank? || !can_show_result?
      end

      def home
        @all_geocoded_results = results.geocoded
      end

      private

      def can_show_result?
        return true if current_user&.admin?

        result.published?
      end

      def results
        @results ||= begin
          parent_id = params[:parent_id].presence
          query = search.result.where(parent_id:)

          query = reorder(query)
          paginate(query)
        end
      end

      def geocoded_results
        @geocoded_results ||= search.result.geocoded_data
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
        @result ||= Result.includes(:milestones).where(component: current_component).find(params[:id])
      end

      def search_collection
        Result.where(component: current_component).published
      end

      def default_filter_params
        {
          search_text_cont: "",
          taxonomies_part_of_contains: "",
          favorites: nil,
          with_any_tag: []
        }
      end

      def first_class_taxonomies
        @first_class_taxonomies ||= current_organization.taxonomies.where(parent_id: current_component.available_root_taxonomies, id: current_component.available_taxonomy_ids)
      end

      def count_calculator(taxonomy_id)
        Decidim::Accountability::ResultsCalculator.new(current_component, taxonomy_id).count
      end

      def controller_breadcrumb_items
        @controller_breadcrumb_items ||= []
      end

      def set_controller_breadcrumb
        controller_breadcrumb_items << breadcrumb_item
      end

      def breadcrumb_item
        return {} if result&.parent.blank?

        {
          label: translated_attribute(result.parent.title),
          url: result_path(result.parent),
          active: true
        }
      end
    end
  end
end
