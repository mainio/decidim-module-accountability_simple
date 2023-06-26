# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultLinkAttributes < GraphQL::Schema::InputObject
      graphql_name "ResultLinkAttributes"
      description "A result link attributes"

      argument :id, GraphQL::Types::ID, required: false
      argument :position, GraphQL::Types::Int, required: true
      argument :label, GraphQL::Types::JSON, required: true
      argument :url, GraphQL::Types::JSON, required: true
    end
  end
end
