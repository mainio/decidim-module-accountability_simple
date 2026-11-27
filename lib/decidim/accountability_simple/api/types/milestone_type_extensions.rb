# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Api
      module MilestoneTypeExtensions
        def self.included(type)
          type.own_fields.delete("title")

          type.field :end_date, Decidim::Core::DateType, "The end date for this milestone", null: true
          type.field :title, Decidim::Core::TranslatedFieldType, "The title for this milestone (that overrides the dates)", null: false
        end
      end
    end
  end
end
