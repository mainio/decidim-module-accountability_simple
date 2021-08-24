# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module CreateStatusExtensions
        extend ActiveSupport::Concern

        included do
          private

          def create_status
            @status = Decidim::AccountabilityStatus.create!(
              component: @form.current_component,
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
