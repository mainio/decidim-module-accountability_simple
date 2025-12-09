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
          @available_orders ||= %w(alphabetical).tap do |orders|
            orders << "scope" if current_component.scopes_enabled?
            orders << "category"
          end
        end


        def default_order
          "alphabetical"
        end

        def reorder(results)
          case order
          when "scope"
            results.left_joins(:scope).order(
              Arel.sql(
                "decidim_scopes.name->>'#{current_locale}', decidim_accountability_results.title->>'#{current_locale}'"
              )
            )
          when "category"
            results.left_joins(:category).order(
              Arel.sql(
                "decidim_categories.name->>'#{current_locale}', decidim_accountability_results.title->>'#{current_locale}'"
              )
            )
          else # "alphabetical"
            results.order(Arel.sql("decidim_accountability_results.title->>'#{current_locale}'"))
          end
        end
      end
    end
  end
end
