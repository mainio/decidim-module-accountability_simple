# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # The result link collection attributes for managing a result link
    # collection.
    class ResultLinkCollectionAttributes < GraphQL::Schema::InputObject
      description "Attributes for result link collections"

      argument :position, GraphQL::Types::Int, description: "The result link collection position, lowest first", required: false, default_value: 0
      argument :key, GraphQL::Types::String, description: "The attachment collection key, i.e. its technical handle", required: false
      argument :name, GraphQL::Types::JSON, description: "The attachment collection name localized hash, e.g. {\"en\": \"English name\"}", required: true
    end
  end
end
