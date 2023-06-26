# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This type represents a detail value type for results.
    class ResultLinkType < GraphQL::Schema::Object
      graphql_name "ResultLinkType"
      description "A link for results"

      field :id, GraphQL::Types::ID, "The internal ID for this link", null: false
      field :position, GraphQL::Types::Int, description: "The position of this link", null: false
      field :label, Decidim::Core::TranslatedFieldType, description: "The label of this link.", null: false
      field :url, Decidim::Core::TranslatedFieldType, description: "The URL of this link.", null: false
    end
  end
end
