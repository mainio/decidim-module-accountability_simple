# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This type represents a detail value type for results.
    # Needs to use the old GraphQL API because of the record these are attached
    # to.
    ResultDetailValueType = GraphQL::ObjectType.define do
      name "ResultDetailValueType"
      description "A detail value for results"

      field :id, !types.ID, "The internal ID for this detail value"
      # field :detail, !Decidim::AccountabilitySimple::ResultDetailType, "The result detail object for the detail value."
      field :description, !Decidim::Core::TranslatedFieldType, "The description of this detail value."
    end

    # To update to the new GraphQL API
    # class ResultDetailValueType < GraphQL::Schema::Object
    #   graphql_name "ResultDetailValueType"
    #   description "A detail value for results"

    #   field :id, GraphQL::Types::ID, "The internal ID for this detail value", null: false
    #   field :detail, Decidim::AccountabilitySimple::ResultDetail, description: "The result detail object for the detail value.", null: false
    #   field :description, Decidim::Core::TranslatedFieldType, description: "The description of the value.", null: false
    # end
  end
end
