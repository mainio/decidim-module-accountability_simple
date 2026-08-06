# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module CreateMilestoneExtensions
        extend ActiveSupport::Concern

        included do
          private

          def create_milestone
            @milestone = Decidim::Accountability::Milestone.create!(
              decidim_accountability_result_id: @form.decidim_accountability_result_id,
              entry_date: @form.entry_date,
              end_date: @form.end_date,
              title: @form.title,
              description: @form.description
            )
          end
        end
      end
    end
  end
end
