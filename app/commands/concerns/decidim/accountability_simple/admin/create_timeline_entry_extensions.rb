# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module CreateTimelineEntryExtensions
        extend ActiveSupport::Concern

        included do
          private

          def create_timeline_entry
            @timeline_entry = Decidim::Accountability::TimelineEntry.create!(
              decidim_accountability_result_id: @form.decidim_accountability_result_id,
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
