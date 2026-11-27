# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # Adds the orders methods to the controllers that list projects.
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        private

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= %w(alphabetical)
        end

        def default_order
          "alphabetical"
        end

        def reorder(results)
          # Scopes and categories are removed. A record can have multiple taxonomies so ordering based on those is not
          # worth it either

          results.order(Arel.sql("decidim_accountability_results.title->>'#{current_locale}'"))
        end
      end
    end
  end
end
