# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This class handles the calculation of progress for a set of results
    class ResultsCalculator
      # Public: Initializes the service.
      def initialize(scope_id, category_id)
        @scope_id = scope_id
        @category_id = category_id
      end

      delegate :count, to: :results

      def progress
        results.average("COALESCE(progress, 0)")
      end

      private

      attr_reader :scope_id, :category_id

      def results
        @results ||= Decidim::Accountability::ResultSearch.new(
          scope_id: scope_id,
          category_id: category_id,
          deep_search: false
        ).results
      end
    end
  end
end
