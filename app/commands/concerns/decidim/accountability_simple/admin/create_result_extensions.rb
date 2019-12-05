# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module CreateResultExtensions
        extend ActiveSupport::Concern

        included do
          private

          def create_result
            params = {
              component: @form.current_component,
              scope: @form.scope,
              category: @form.category,
              parent_id: @form.parent_id,
              title: @form.title,
              description: @form.description,
              start_date: @form.start_date,
              end_date: @form.end_date,
              progress: @form.progress,
              decidim_accountability_status_id: @form.decidim_accountability_status_id,
              external_id: @form.external_id.presence,
              weight: @form.weight,
              main_image: @form.main_image,
              list_image: @form.list_image
            }

            @result = Decidim.traceability.create!(
              Decidim::Accountability::Result,
              @form.current_user,
              params,
              visibility: "all"
            )
          end
        end
      end
    end
  end
end
