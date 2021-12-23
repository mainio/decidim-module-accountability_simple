# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This type represents a detail value type for results.
    # Needs to use the old GraphQL API because of the record these are attached
    # to.
    ResultLinkType = GraphQL::ObjectType.define do
      name "ResultLinkType"
      description "A link for results"

      field :id, !types.ID, "The internal ID for this link"
      field :position, !types.Int, "The position of this link"
      field :label, !Decidim::Core::TranslatedFieldType, "The label of this link"
      field :url, !Decidim::Core::TranslatedFieldType, "The URL of this link"
    end

    # To update to the new GraphQL API
    # class ResultLinkType < GraphQL::Schema::Object
    #   graphql_name "ResultLinkType"
    #   description "A link for results"

    #   field :id, GraphQL::Types::ID, "The internal ID for this link", null: false
    #   field :position, GraphQL::Types::Int, description: "The position of this link", null: false
    #   field :label, Decidim::Core::TranslatedFieldType, description: "The label of this link.", null: false
    #   field :url, Decidim::Core::TranslatedFieldType, description: "The URL of this link.", null: false
    # end
  end
end
