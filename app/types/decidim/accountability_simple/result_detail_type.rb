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
      field :values, !types[Decidim::AccountabilitySimple::ResultDetailValueType]
    end

    # To update to the new GraphQL API
    # class ResultDetailType < GraphQL::Schema::Object
    #   graphql_name "ResultDetailType"
    #   description "A detail for results"

    #   field :id, GraphQL::Types::ID, "The internal ID for this detail", null: false
    #   field :position, GraphQL::Types::Int, description: "The position of this detail", null: false
    #   field :title, Decidim::Core::TranslatedFieldType, description: "The title of this detail.", null: false
    #   field :icon, GraphQL::Types::String, description: "The icon handle of this detail", null: true
    # end
  end
end