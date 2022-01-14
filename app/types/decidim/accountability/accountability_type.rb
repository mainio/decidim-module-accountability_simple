# frozen_string_literal: true

# Overrides the decidim-accountability AccountabilityType in order to control
# who sees the unpublished results through the API.
module Decidim
  module Accountability
    AccountabilityType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Accountability"
      description "An accountability component of a participatory space."

      connection :results, ResultType.connection_type do
        resolve ->(component, _args, ctx) {
                  ResultTypeHelper.base_scope(component, ctx[:current_user]).includes(:component)
                }
      end

      field(:result, ResultType) do
        argument :id, !types.ID

        resolve ->(component, args, ctx) {
          ResultTypeHelper.base_scope(component, ctx[:current_user]).find_by(id: args[:id])
        }
      end
    end

    module ResultTypeHelper
      def self.base_scope(component, current_user = nil)
        if current_user&.admin?
          Result.where(component: component)
        else
          Result.where(component: component).published
        end
      end
    end
  end
end
