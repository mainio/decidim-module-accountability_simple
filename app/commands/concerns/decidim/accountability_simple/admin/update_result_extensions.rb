# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module UpdateResultExtensions
        extend ActiveSupport::Concern

        include Decidim::Tags::TaggingsCommand
        include Decidim::Locations::LocationsCommand

        included do
          private

          def update_result
            Decidim.traceability.update!(
              result,
              @form.current_user,
              attributes
            )

            update_result_authors
            update_result_default_details
            update_result_details
            update_result_links
            update_taggings(result, @form)
            update_locations(result, @form)

            link_ideas
            link_plans
          end

          def attributes
            {
              scope: @form.scope,
              category: @form.category,
              parent_id: @form.parent_id,
              title: @form.title,
              description: @form.description,
              summary: @form.summary,
              start_date: @form.start_date,
              end_date: @form.end_date,
              progress: @form.progress,
              decidim_accountability_status_id: @form.decidim_accountability_status_id,
              external_id: @form.external_id.presence,
              weight: @form.weight,
              use_default_details: @form.use_default_details
            }.merge(uploader_attributes)
          end

          def uploader_attributes
            {
              main_image: @form.main_image,
              list_image: @form.list_image
            }.delete_if { |_k, val| val.is_a?(Decidim::ApplicationUploader) }
          end
        end

        def update_result_authors
          result.coauthorships.destroy_all
          @form.authors.each do |author|
            result.add_coauthor(author)
          end
        end

        def update_result_default_details
          @form.result_default_details.each do |form_default_detail|
            update_result_default_detail(form_default_detail)
          end
        end

        def update_result_details
          @form.result_details.each do |form_result_detail|
            update_result_detail(form_result_detail)
          end
        end

        def update_result_default_detail(form_default_detail)
          record = Decidim::AccountabilitySimple::ResultDetail.find(
            form_default_detail.id
          )

          value = record.value_for(@result) || record.values.build(result: @result)
          value.attributes = { description: form_default_detail.description }
          value.save!
        end

        def update_result_detail(form_result_detail)
          result_detail_attributes = {
            title: form_result_detail.title,
            icon: form_result_detail.icon,
            position: form_result_detail.position
          }

          record = @result.result_details.find_by(id: form_result_detail.id) ||
                   @result.result_details.build(result_detail_attributes)

          if record.persisted?
            if form_result_detail.deleted?
              record.destroy!
            else
              record.update!(result_detail_attributes)
            end
          else
            record.save!
          end

          value = record.value_for(@result) || record.values.build(result: @result)
          value.attributes = { description: form_result_detail.description }
          value.save!

          record
        end

        def update_result_links
          @form.result_links.each do |form_result_link|
            update_result_link(form_result_link)
          end
        end

        def update_result_link(form_result_link)
          result_link_attributes = {
            label: form_result_link.label,
            url: form_result_link.url,
            position: form_result_link.position
          }

          record = @result.result_links.find_by(id: form_result_link.id) ||
                   @result.result_links.build(result_link_attributes)

          if record.persisted?
            if form_result_link.deleted?
              record.destroy!
            else
              record.update!(result_link_attributes)
            end
          else
            record.save!
          end

          record
        end

        def link_ideas
          return unless @form.idea_ids

          result.link_resources(ideas, "included_ideas")
        end

        def link_plans
          return unless @form.plan_ids

          result.link_resources(plans, "included_plans")
        end

        def ideas
          @ideas ||= result.sibling_scope(:ideas).where(id: @form.idea_ids)
        end

        def plans
          @plans ||= result.sibling_scope(:plans).where(id: @form.plan_ids)
        end
      end
    end
  end
end
