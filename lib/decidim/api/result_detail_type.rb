# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This type represents a detail value type for results.
    class ResultDetailType < GraphQL::Schema::Object
      graphql_name "ResultDetailType"
      description "A detail for results"

      field :id, GraphQL::Types::ID, "The internal ID for this detail", null: false
      field :position, GraphQL::Types::Int, description: "The position of this detail", null: false
      field :title, Decidim::Core::TranslatedFieldType, description: "The title of this detail.", null: false
      field :icon, GraphQL::Types::String, description: "The icon handle of this detail", null: true
      field :values, [Decidim::AccountabilitySimple::ResultDetailValueType], null: false

      def values
        parent = context.scoped_context[:parent]
        if parent && parent.is_a?(Decidim::Accountability::Result)
          value = object.value_for(parent)
          return [value].compact
        end

        # Default e.g. for component context, return all values
        object.values
      end
    end
  end
end
