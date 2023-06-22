# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command gets called when a result is unpublished from the admin
      # panel.
      class UnpublishResult < Rectify::Command
        # Public: Initializes the command.
        #
        # result - The result to unpublish.
        # current_user - the user performing the action
        def initialize(result, current_user)
          @result = result
          @current_user = current_user
        end

        # Public: Unpublishes the Result.
        #
        # Broadcasts :ok if unpublished, :invalid otherwise.
        def call
          return broadcast(:invalid) unless result.published?

          unpublish_result

          broadcast(:ok)
        end

        private

        attr_reader :result, :current_user

        def unpublish_result
          Decidim.traceability.perform_action!(
            :unpublish,
            result,
            current_user
          ) do
            result.unpublish!
            result
          end
        end
      end
    end
  end
end
