# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Api
      module TimelineEntryTypeExtensions
        def self.included(type)
          type.field :end_date, Decidim::Core::DateType, "The end date for this timeline entry", null: true
          type.field :title, Decidim::Core::TranslatedFieldType, "The title for this timeline entry (that overrides the dates)", null: false
        end
      end
    end
  end
end
