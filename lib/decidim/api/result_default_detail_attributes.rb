# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultDefaultDetailAttributes < GraphQL::Schema::InputObject
      graphql_name "ResultDefaultDetailAttributes"
      description "A result default detail attributes"

      argument :description, GraphQL::Types::JSON, description: "The description of this default detail", required: true
      argument :detail_id, GraphQL::Types::ID, description: "The ID of this default detail", required: true
    end
  end
end
