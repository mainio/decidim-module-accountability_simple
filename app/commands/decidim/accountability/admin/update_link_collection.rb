# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user updates a ResultLinkCollection
      # for a Result from the admin panel.
      class UpdateLinkCollection < Decidim::Command
        def initialize(form, link_collection)
          @form = form
          @link_collection = link_collection
        end

        # Updates the link collection if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            update_link_collection
          end

          broadcast(:ok, link_collection)
        end

        private

        attr_reader :link_collection

        def update_link_collection
          Decidim.traceability.update!(
            link_collection,
            @form.current_user,
            params
          )
        end

        def params
          {
            key: @form.key,
            name: @form.name,
            position: @form.position
          }
        end
      end
    end
  end
end
