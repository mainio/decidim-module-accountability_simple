# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module ResultFormExtensions
        extend ActiveSupport::Concern

        include Decidim::HasUploadValidations
        include Decidim::Tags::TaggableForm
        include Decidim::Locations::LocatableForm

        included do
          translatable_attribute :summary, String

          attribute :main_image, Decidim::Attributes::Blob
          attribute :list_image, Decidim::Attributes::Blob
          attribute :remove_main_image, Decidim::AttributeObject::Model::Boolean, default: false
          attribute :remove_list_image, Decidim::AttributeObject::Model::Boolean, default: false
          attribute :use_default_details, Decidim::AttributeObject::Model::Boolean, default: true
          attribute :author_ids, Array[Integer]

          attribute :idea_ids, Array[Integer]
          attribute :plan_ids, Array[Integer]

          attribute :result_default_details, Array[ResultDefaultDetailsForm]
          attribute :result_details, Array[ResultDetailsForm]
          attribute :result_links, Array[ResultLinkForm]

          validates :main_image, passthru: {
            to: Decidim::Accountability::Result,
            with: { component: ->(form) { form.current_component } }
          }
          validates :list_image, passthru: {
            to: Decidim::Accountability::Result,
            with: { component: ->(form) { form.current_component } }
          }

          validates_locations_for Decidim::Accountability::Result

          alias_method :map_model_original, :map_model
          alias_method :organization, :current_organization

          def map_model(model)
            map_model_original(model)

            self.author_ids = model.coauthorships.pluck(:decidim_author_id)
            self.result_default_details = model.result_default_details.map do |default_detail|
              default_detail_form = ResultDefaultDetailsForm.from_model(default_detail)
              default_detail_form.description = default_detail.values.find_by(
                result: model
              ).try(:description)

              default_detail_form
            end
            self.result_details = model.result_details.map do |result_detail|
              ResultDetailsForm.from_model(result_detail)
            end

            self.idea_ids = model.linked_resources(:ideas, "included_ideas").pluck(:id)
            self.plan_ids = model.linked_resources(:plans, "included_plans").pluck(:id)

            map_locations(model.locations)
          end

          def authors
            @authors ||= Decidim::UserBaseEntity.where(id: author_ids)
          end
        end

        def ideas
          return [] unless defined?(Decidim::Ideas::Idea)

          @ideas ||= Decidim.find_resource_manifest(:ideas).try(:resource_scope, current_component)
                         &.where(id: idea_ids)
                         &.order(title: :asc)
        end

        def plans
          return [] unless defined?(Decidim::Plans::Plan)

          @plans ||= Decidim.find_resource_manifest(:plans).try(:resource_scope, current_component)
                         &.where(id: plan_ids)
                         &.order(title: :asc)
        end
      end
    end
  end
end
