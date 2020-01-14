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
              list_image: @form.list_image,
              theme_color: @form.theme_color
            }

            @result = Decidim.traceability.create!(
              Decidim::Accountability::Result,
              @form.current_user,
              params,
              visibility: "all"
            )

            create_result_details
          end
        end

        def create_result_details
          @form.result_details.each do |form_result_detail|
            create_result_detail(form_result_detail)
          end
        end

        def create_result_detail(form_result_detail)
          result_detail_attributes = {
            title: form_result_detail.title,
            description: form_result_detail.description,
            icon: form_result_detail.icon,
            position: form_result_detail.position,
            result: @result
          }

          record = Decidim::AccountabilitySimple::ResultDetail.find_or_create_by!(
            result_detail_attributes
          )

          yield record if block_given?

          if record.persisted?
            if form_result_detail.deleted?
              record.destroy!
            else
              record.update!(result_detail_attributes)
            end
          else
            record.save!
          end
        end
      end
    end
  end
end
