# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultMilestoneMutationType < GraphQL::Schema::Object
      include Decidim::AccountabilitySimple::Api::Permissions

      graphql_name "ResultMilestoneMutation"
      description "A result milestone which includes its available mutations"

      field :result_id, GraphQL::Types::ID, null: false do
        description "Result ID"
      end

      field :create, Decidim::Accountability::MilestoneType, null: true do
        description "Add a new milestone to a result"

        argument :description, GraphQL::Types::JSON, description: "The milestone description (HTML)", required: true
        argument :end_date, GraphQL::Types::ISO8601Date, description: "The milestone end date", required: false
        argument :entry_date, GraphQL::Types::ISO8601Date, description: "The milestone date", required: true
        argument :title, GraphQL::Types::JSON, description: "Use this to override the date of this entry", required: false
      end

      field :update, Decidim::Accountability::MilestoneType, null: true do
        description "Add a new milestone to a result"

        argument :description, GraphQL::Types::JSON, description: "The milestone description (HTML)", required: true
        argument :end_date, GraphQL::Types::ISO8601Date, description: "The milestone end date", required: false
        argument :entry_date, GraphQL::Types::ISO8601Date, description: "The milestone date", required: true
        argument :id, GraphQL::Types::ID, description: "The milestone ID", required: true
        argument :title, GraphQL::Types::JSON, description: "Use this to override the date of this entry", required: false
      end

      field :destroy, Decidim::Accountability::MilestoneType, null: true do
        description "Destroys a milestone from a result"

        argument :id, GraphQL::Types::ID, "The milestone's id to destroy", required: true
      end

      def create(entry_date:, description:, end_date: nil, title: nil)
        enforce_permission_to :create, :milestone

        form = Decidim::Accountability::Admin::MilestoneForm.from_params(
          "milestone" => {
            "decidim_accountability_result_id" => object.id,
            "entry_date" => entry_date,
            "end_date" => end_date,
            "description" => description,
            "title" => title
          }
        ).with_context(
          current_organization:,
          current_component: object.component,
          current_user:
        )

        Decidim::Accountability::Admin::CreateMilestone.call(form) do
          on(:ok) do |entry|
            return entry
          end

          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.accountability.admin.milestones.create.invalid")
        )
      end

      def update(id:, entry_date:, description:, end_date: nil, title: nil)
        entry = object.milestones.find_by(id:)
        unless entry
          return GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.milestones.update.invalid")
          )
        end
        enforce_permission_to :update, :milestone, milestone: entry

        form = Decidim::Accountability::Admin::MilestoneForm.from_params(
          "milestone" => {
            "decidim_accountability_result_id" => entry.id,
            "entry_date" => entry_date,
            "end_date" => end_date,
            "description" => description,
            "title" => title
          }
        ).with_context(
          current_organization:,
          current_component: object.component,
          current_user:
        )

        Decidim::Accountability::Admin::UpdateMilestone.call(form, entry) do
          on(:ok) do
            return entry
          end

          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.accountability.admin.milestones.update.invalid")
        )
      end

      def destroy(id:)
        entry = object.milestones.find_by(id:)
        unless entry
          return GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.milestones.update.invalid")
          )
        end
        enforce_permission_to :destroy, :milestone, milestone: entry

        entry.destroy!
        entry
      end

      private

      def current_organization
        context[:current_organization]
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
