# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This type represents a detail value type for results.
    # Needs to use the old GraphQL API because of the record these are attached
    # to.
    ResultDetailType = GraphQL::ObjectType.define do
      name "ResultDetailType"
      description "A detail for results"

      field :id, !types.ID, "The internal ID for this detail"
      field :position, !types.Int, "The position of this detail"
      field :title, !Decidim::Core::TranslatedFieldType, "The title of this detail."
      field :icon, types.String, "The icon handle of this detail"
      field :values, !types[Decidim::AccountabilitySimple::ResultDetailValueType], "The current installation's name." do
        resolve ->(obj, _args, ctx) {
          parent_ctx = ctx.parent&.parent
          if parent_ctx && parent_ctx.object.is_a?(Decidim::Accountability::Result)
            result = parent_ctx.object
            return [obj.value_for(result)]
          end

          # Default e.g. for component context, return all values
          obj.values
        }
      end
    end

    # To update to the new GraphQL API
    # class ResultDetailType < GraphQL::Schema::Object
    #   graphql_name "ResultDetailType"
    #   description "A detail for results"

    #   field :id, GraphQL::Types::ID, "The internal ID for this detail", null: false
    #   field :position, GraphQL::Types::Int, description: "The position of this detail", null: false
    #   field :title, Decidim::Core::TranslatedFieldType, description: "The title of this detail.", null: false
    #   field :icon, GraphQL::Types::String, description: "The icon handle of this detail", null: true
    #   field :values, Decidim::AccountabilitySimple::ResultDetailValueType, null: false

    #   def values
    #     parent_ctx = context.parent&.parent
    #     if parent_ctx && parent_ctx.object.is_a?(Decidim::Accountability::Result)
    #       result = parent_ctx.object
    #       return [object.value_for(result)]
    #     end
    #
    #     # Default e.g. for component context, return all values
    #     object.values
    #   end
    # end
  end
end
