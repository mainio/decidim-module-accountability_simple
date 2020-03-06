# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This class handles the calculation of progress for a set of results
    class ResultSearch < Decidim::Accountability::ResultSearch
      # Creates the SearchLight base query.
      def base_query
        unless options[:included_components].empty?
          @scope = @scope.where(
            component: options[:included_components]
          )
        end

        @scope
      end

      # Handle component_id filter
      def search_component_id
        component_id = options[:component_id]
        return query if component_id.blank?

        query.where(decidim_component_id: component_id)
      end

      private

      def category_ids
        [category_id.to_i]
      end
    end
  end
end
