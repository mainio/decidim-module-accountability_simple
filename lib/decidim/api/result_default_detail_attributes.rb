# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultDefaultDetailAttributes < GraphQL::Schema::InputObject
      graphql_name "ResultDefaultDetailAttributes"
      description "A result default detail attributes"

      argument :detail_id, GraphQL::Types::ID, required: true
      argument :description, GraphQL::Types::JSON, required: true
    end
  end
end
