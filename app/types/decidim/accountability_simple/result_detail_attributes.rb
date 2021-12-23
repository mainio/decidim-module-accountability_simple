# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultDetailAttributes < GraphQL::Schema::InputObject
      graphql_name "ResultDetailAttributes"
      description "A result detail attributes"

      argument :detail_id, ID, required: false
      argument :position, GraphQL::Types::Int, required: true
      argument :icon, GraphQL::Types::String, required: true
      argument :title, GraphQL::Types::JSON, required: true
      argument :description, GraphQL::Types::JSON, required: true
    end
  end
end
