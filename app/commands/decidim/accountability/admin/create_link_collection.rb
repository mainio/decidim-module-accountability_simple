# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a ResultLinkCollection
      # for a Result from the admin panel.
      class CreateLinkCollection < Decidim::Command
        def initialize(form)
          @form = form
        end

        # Creates the link collection if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_link_collection
          end

          broadcast(:ok, link_collection)
        end

        private

        attr_reader :link_collection

        def create_link_collection
          @link_collection = Decidim.traceability.create!(
            AccountabilitySimple::ResultLinkCollection,
            @form.current_user,
            params,
            visibility: "all"
          )
        end

        def params
          {
            decidim_accountability_result_id: @form.decidim_accountability_result_id,
            key: @form.key,
            name: @form.name,
            position: @form.position
          }
        end
      end
    end
  end
end
