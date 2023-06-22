# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This interface represents a linked resource that can be of any type. The
    # only requirement is to have an ID and the Type name be the class.name +
    # Type
    ResourceLinkInterface = GraphQL::InterfaceType.define do
      name "ResultResourceLinkInterface"
      description "An interface that represents a linked resource"

      field :id, !types.ID, "ID of this entity"

      resolve_type ->(obj, _ctx) {
        "#{obj.class.name}Type".constantize
      }
    end
  end
end
