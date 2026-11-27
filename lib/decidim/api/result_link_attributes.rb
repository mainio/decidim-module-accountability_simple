# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultLinkAttributes < GraphQL::Schema::InputObject
      graphql_name "ResultLinkAttributes"
      description "A result link attributes"

      argument :collection, Decidim::AccountabilitySimple::ResultLinkCollectionInput, description: "A result link collection", required: false
      argument :id, GraphQL::Types::ID, description: "The ID of this link", required: false
      argument :label, GraphQL::Types::JSON, description: "The label of this link", required: true
      argument :position, GraphQL::Types::Int, description: "The position of this link", required: true
      argument :url, GraphQL::Types::JSON, description: "The URL of this link", required: true
    end
  end
end
