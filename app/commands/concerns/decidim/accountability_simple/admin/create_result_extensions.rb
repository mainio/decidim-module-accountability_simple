# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module CreateResultExtensions
        extend ActiveSupport::Concern

        include Decidim::Tags::TaggingsCommand
        include Decidim::Locations::LocationsCommand
        include Decidim::AttachmentAttributesMethods

        included do
          private

          attr_reader :form # Needed for attachment_attributes

          def create_result
            params = {
              component: @form.current_component,
              scope: @form.scope,
              category: @form.category,
              parent_id: @form.parent_id,
              title: @form.title,
              summary: @form.summary,
              description: @form.description,
              start_date: @form.start_date,
              end_date: @form.end_date,
              progress: @form.progress,
              decidim_accountability_status_id: @form.decidim_accountability_status_id,
              external_id: @form.external_id.presence,
              weight: @form.weight,
              use_default_details: @form.use_default_details
            }.merge(attachment_attributes(:main_image, :list_image)).merge(extra_attributes)

            @result = Decidim.traceability.create!(
              Decidim::Accountability::Result,
              @form.current_user,
              params,
              visibility: "all"
            )

            create_result_authors
            create_result_default_details
            create_result_details
            create_result_links
            update_taggings(@result, @form)
            update_locations(@result, @form)

            link_ideas
            link_plans
          end
        end

        # Allows customizing extra attributes to the results outside of this
        # module.
        def extra_attributes
          {}
        end

        def create_result_authors
          @form.authors.each do |author|
            @result.add_coauthor(author)
          end
        end

        def create_result_default_details
          @form.result_default_details.each do |form_default_detail|
            create_result_default_detail(form_default_detail)
          end
        end

        def create_result_details
          @form.result_details.each do |form_result_detail|
            create_result_detail(form_result_detail)
          end
        end

        def create_result_default_detail(form_default_detail)
          record = Decidim::AccountabilitySimple::ResultDetail.find(
            form_default_detail.id
          )

          value = record.value_for(@result) || record.values.build(result: @result)
          value.attributes = { description: form_default_detail.description }
          value.save!
        end

        def create_result_detail(form_result_detail)
          result_detail_attributes = {
            title: form_result_detail.title,
            icon: form_result_detail.icon,
            position: form_result_detail.position,
            accountability_result_detailable: @result
          }

          record = Decidim::AccountabilitySimple::ResultDetail.find_or_create_by!(
            result_detail_attributes
          )

          yield record if block_given?

          if record.persisted?
            if form_result_detail.deleted?
              record.destroy!
              return
            end

            record.update!(result_detail_attributes)
          else
            record.save!
          end

          value = record.value_for(@result) || record.values.build(result: @result)
          value.attributes = { description: form_result_detail.description }
          value.save!

          record
        end

        def create_result_links
          @form.result_links.each do |form_result_link|
            create_result_link(form_result_link)
          end
        end

        def create_result_link(form_result_link)
          result_link_attributes = {
            link_collection: @result.result_link_collections.find_by(id: form_result_link.collection_id),
            label: form_result_link.label,
            url: form_result_link.url,
            position: form_result_link.position,
            result: @result
          }

          @result.result_links.create!(result_link_attributes)
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
