# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Api
      module AccountabilityTypeExtensions
        def self.included(type)
          type.field :statuses, [Decidim::Accountability::StatusType], null: false
          type.field :available_details, [Decidim::AccountabilitySimple::ResultDetailType], "The available details for the record", null: false

          # Overridden methods from the original class
          type.class_eval do
            def results
              results_scope.includes(:component)
            end

            def result(**args)
              results_scope.find_by(id: args[:id])
            end
          end
        end

        def statuses
          Decidim::Accountability::Status.where(component: object)
        end

        def available_details
          context.scoped_context.merge!(parent: object)

          Decidim::AccountabilitySimple::ResultDetail.where(
            accountability_result_detailable: object
          )
        end

        private

        def results_scope
          if context[:current_user]&.admin?
            Decidim::Accountability::Result.where(component: object)
          else
            Decidim::Accountability::Result.where(component: object).published
          end
        end
      end
    end
  end
end
