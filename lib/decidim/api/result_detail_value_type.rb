# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This type represents a detail value type for results.
    class ResultDetailValueType < GraphQL::Schema::Object
      graphql_name "ResultDetailValueType"
      description "A detail value for results"

      field :id, GraphQL::Types::ID, "The internal ID for this detail value", null: false
      field :detail, Decidim::AccountabilitySimple::ResultDetailType, description: "The result detail object for the detail value.", null: false
      field :description, Decidim::Core::TranslatedFieldType, description: "The description of the value.", null: false
    end
  end
end
