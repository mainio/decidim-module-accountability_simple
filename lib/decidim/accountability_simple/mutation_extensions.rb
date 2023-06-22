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
      def self.define(type)
        type.field :result, Decidim::AccountabilitySimple::ResultMutationType do
          description "A result"

          argument :id, !types.ID, description: "The result's id"

          resolve lambda { |_obj, args, _ctx|
            Decidim::Accountability::Result.find(args[:id])
          }
        end

        type.field :resultTimelineEntry, Decidim::AccountabilitySimple::ResultTimelineEntryMutationType do
          description "A result timeline entry"

          argument :resultId, !types.ID, description: "The result's id"

          resolve lambda { |_obj, args, _ctx|
            Decidim::Accountability::Result.find(args[:resultId])
          }
        end
      end
    end
  end
end
