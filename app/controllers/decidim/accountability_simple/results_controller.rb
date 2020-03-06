# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # Exposes the result resource so users can view them
    class ResultsController < Decidim::AccountabilitySimple::ApplicationController
      include FilterResource
      helper Decidim::WidgetUrlsHelper
      helper Decidim::TraceabilityHelper
      helper Decidim::Accountability::BreadcrumbHelper
      helper Decidim::TooltipHelper

      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      # helper Decidim::ResourceReferenceHelper
      helper Decidim::TranslationsHelper
      # helper Decidim::IconHelper
      helper Decidim::ResourceHelper
      helper Decidim::ScopesHelper
      # helper Decidim::ActionAuthorizationHelper
      # helper Decidim::AttachmentsHelper
      helper Decidim::SanitizeHelper
      helper Decidim::PadHelper

      # helper Decidim::Accountability::ApplicationHelper

      helper_method :results, :result, :components, :categories, :count_calculator

      private

      def results
        parent_id = params[:parent_id].presence
        @results ||= search.results.where(parent_id: parent_id).page(params[:page]).per(12)
      end

      def result
        @result ||= Decidim::Accountability::Result.includes(:timeline_entries).find(params[:id])
      end

      def components
        @components ||= Decidim::Component.where(manifest_name: :accountability).where.not(published_at: nil)
      end

      def search_klass
        ResultSearch
      end

      def default_filter_params
        {
          search_text: "",
          scope_id: "",
          category_id: "",
          component_id: ""
        }
      end

      def categories
        return selected_component.categories if selected_component

        []
      end

      def context_params
        { organization: current_organization }
      end

      def selected_component
        @selected_component ||= Decidim::Component.find_by(id: filter.component_id)
      end

      def count_calculator(scope_id, category_id)
        Decidim::Accountability::ResultsCalculator.new(scope_id, category_id).count
      end
    end
  end
end
