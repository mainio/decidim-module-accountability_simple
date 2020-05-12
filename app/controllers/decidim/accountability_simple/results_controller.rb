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

      helper_method :results, :result, :selected_space, :components, :categories, :count_calculator

      # This is used for "clean" URLs to display results only from a specific
      # participatory process groups. The group name slug is given to the URL
      # as the ID parameter and that is used to match the participatory process
      # group names by replacing special characters from the names and
      # converting dashes into spaces.
      #
      # The following extra characters of the process group's name will be
      # stripped out:
      # '.', ',', '-', '!', '¡', '?', '¿', '%', '$', '€', '£', '"', "'"
      #
      # Therefore, the user could, for example, request the following URL:
      #   /results/my-special-process-group
      #
      # And they would see all results for the participatory process group with
      # the following matchin name in any language:
      # - My Spécîäl Pröcêss Grôûp.
      def show
        slug = params[:id]
        @space = Decidim::ParticipatoryProcess.find_by(slug: slug)
        return render :index if @space

        search = slug.gsub(/-/, " ")

        subq_parts = []
        subq_args = []
        current_organization.available_locales.each do |locale|
          subq_parts << "translate(regexp_replace(lower(name->>'#{locale}'), ?, ''), ?, ?) LIKE ?"
          subq_args << "[\\.\\-,!¡?¿%$€£\"']"
          subq_args << "á,à,â,ä,å,é,è,ê,ë,í,ì,î,ï,ú,ù,û,ü,ó,ò,ô,ö"
          subq_args << "a,a,a,a,a,e,e,e,e,i,i,i,i,u,u,u,u,o,o,o,o"
          subq_args << search
        end

        @process_group = Decidim::ParticipatoryProcessGroup.where(
          organization: current_organization
        ).find_by(subq_parts.join(" OR "), *subq_args)

        raise ActionController::RoutingError, "Not Found" unless @process_group

        render :index
      end

      private

      def results
        parent_id = params[:parent_id].presence
        @results ||= search.results.where(parent_id: parent_id).page(params[:page]).per(12)
      end

      def result
        @result ||= Decidim::Accountability::Result.includes(:timeline_entries).find(params[:id])
      end

      def components
        @components ||= begin
          if spaces.empty?
            Decidim::Component.where(manifest_name: :accountability)
          else
            Decidim::Component.where(manifest_name: :accountability, participatory_space: spaces)
          end
        end.where.not(published_at: nil)
      end

      def spaces
        @spaces ||= begin
          if @process_group
            @process_group.participatory_processes
          elsif @space
            [@space]
          else
            []
          end
        end
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
        { organization: current_organization, included_components: components }
      end

      def selected_component
        @selected_component ||= Decidim::Component.find_by(id: filter.component_id)
      end

      def selected_space
        @selected_space ||= @space || selected_component.try(:participatory_space)
      end

      def count_calculator(scope_id, category_id)
        Decidim::Accountability::ResultsCalculator.new(scope_id, category_id).count
      end
    end
  end
end
