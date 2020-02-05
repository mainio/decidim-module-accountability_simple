# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This class handles the calculation of progress for a set of results
    class ResultSearch < Decidim::Accountability::ResultSearch
      # Creates the SearchLight base query.
      def base_query
        @scope
      end
    end
  end
end
