# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultLinkCollectionType < Decidim::Api::Types::BaseObject
      description "A result link collection"

      field :id, GraphQL::Types::ID, "The id of this link collection", null: false
      field :position, GraphQL::Types::Int, "The position of this link collection", null: false
      field :key, GraphQL::Types::String, "A technical key for the link collection to identify a specific correct collection", null: true
      field :name, Decidim::Core::TranslatedFieldType, "The name of this link collection", null: false
      field :links, [Decidim::AccountabilitySimple::ResultLinkType, { null: true }], "The collection's links", null: false
    end
  end
end
