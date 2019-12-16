# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module UpdateTimelineEntryExtensions
        extend ActiveSupport::Concern

        included do
          private

          def update_timeline_entry
            timeline_entry.update!(
              entry_date: @form.entry_date,
              title: @form.title,
              description: @form.description
            )
          end
        end
      end
    end
  end
end
