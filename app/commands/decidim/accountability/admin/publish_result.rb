# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command gets called when a result is published from the admin
      # panel.
      class PublishResult < Rectify::Command
        # Public: Initializes the command.
        #
        # result - The result to publish.
        # current_user - the user performing the action
        def initialize(result, current_user)
          @result = result
          @current_user = current_user
        end

        # Public: Publishes the Result.
        #
        # Broadcasts :ok if published, :invalid otherwise.
        def call
          return broadcast(:invalid) if result.published?

          publish_result

          broadcast(:ok)
        end

        private

        attr_reader :result, :current_user

        def publish_result
          Decidim.traceability.perform_action!(
            :publish,
            result,
            current_user,
            visibility: "all"
          ) do
            result.publish!
            result
          end
        end
      end
    end
  end
end
