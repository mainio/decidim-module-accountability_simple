# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Milestone
      # for a Result from the admin panel.
      class CreateMilestone < Decidim::Command
        def initialize(form)
          @form = form
        end

        # Creates the milestone if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_milestone
          end

          broadcast(:ok, milestone)
        end

        private

        attr_reader :milestone

        def create_milestone
          @milestone = Milestone.create!(
            decidim_accountability_result_id: @form.decidim_accountability_result_id,
            entry_date: @form.entry_date,
            end_date: @form.end_date,
            description: @form.description
          )
        end
      end
    end
  end
end
