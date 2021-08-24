# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module UpdateStatusExtensions
        extend ActiveSupport::Concern

        included do
          private

          def update_status
            status.update!(
              key: @form.key,
              name: @form.name,
              description: @form.description,
              progress: @form.progress,
              color: @form.color
            )
          end
        end
      end
    end
  end
end
