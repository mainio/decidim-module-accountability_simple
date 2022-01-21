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

      helper_method :results, :geocoded_results, :result, :geocoded_result, :first_class_categories, :count_calculator

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
          orders = %W(title->>'#{current_locale}')
          orders << "title->>'#{current_organization.default_locale}'" if current_organization.default_locale != current_locale

          parent_id = params[:parent_id].presence
          search.results.published.where(parent_id: parent_id).order(*orders).page(params[:page]).per(12)
        end
      end

      def geocoded_results
        @geocoded_results ||= search.results.geocoded_data
      end

      def geocoded_result
        return [] unless current_component.settings.geocoding_enabled

        @geocoded_result ||= Result.where(id: params[:id]).geocoded_data
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
