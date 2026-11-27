# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultDetailAttributes < GraphQL::Schema::InputObject
      graphql_name "ResultDetailAttributes"
      description "A result detail attributes"

      argument :description, GraphQL::Types::JSON, description: "The description of this detail", required: true
      argument :detail_id, GraphQL::Types::ID, description: "The ID of this detail", required: false
      argument :icon, GraphQL::Types::String, description: "The icon of this detail", required: true
      argument :position, GraphQL::Types::Int, description: "The position of this detail", required: true
      argument :title, GraphQL::Types::JSON, description: "The title of this detail", required: true
    end
  end
end
