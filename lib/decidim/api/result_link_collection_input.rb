# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultLinkCollectionInput < GraphQL::Schema::InputObject
      graphql_name "ResultLinkCollectionInput"
      description "A type used for mapping result links to collections"

      argument :id, GraphQL::Types::ID, "Maps the collection using its ID", required: false
      argument :key, GraphQL::Types::String, "Maps the collection using its key", required: false

      def prepare
        id = arguments[:id]
        key = arguments[:key].presence

        raise GraphQL::ExecutionError, "Either id or key needs to be provided." if id.blank? && key.blank?
        raise GraphQL::ExecutionError, "Only one of id or key can be provided at a time." if id.present? && key.present?
        raise GraphQL::ExecutionError, "The key cannot be empty." if !key.nil? && key.empty?

        super
      end

      def id_value
        return arguments[:id].to_i if arguments[:id].present?

        key = arguments[:key].presence
        raise GraphQL::ExecutionError, "The key cannot be empty." if key.blank?
        raise GraphQL::ExecutionError, "Outside of object context." if context[:current_object].blank?

        parent = context[:current_object].object
        raise GraphQL::ExecutionError, "Outside of record context." unless parent

        collection = parent.result_link_collections.find_by(key: key.strip)
        raise GraphQL::ExecutionError, "Key not found within the record's collections." unless collection

        collection.id
      end
    end
  end
end
