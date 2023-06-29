# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This module's job is to extend the API with custom fields related to
    # decidim-accountability_simple.
    module MutationExtensions
      # Public: Extends a type with `decidim-accountability_simple`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :result, Decidim::AccountabilitySimple::ResultMutationType, "A result", null: false do
          argument :id, GraphQL::Types::ID, "The result's id", required: true
        end

        type.field :result_timeline_entry, Decidim::AccountabilitySimple::ResultTimelineEntryMutationType, "A result timeline entry", null: false do
          argument :result_id, GraphQL::Types::ID, "The result's id", required: true
        end
      end

      def result(id:)
        Decidim::Accountability::Result.find(id)
      end

      def result_timeline_entry(result_id:)
        Decidim::Accountability::Result.find(result_id)
      end
    end
  end
end
