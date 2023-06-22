# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultTimelineEntryMutationType < GraphQL::Schema::Object
      include Decidim::AccountabilitySimple::Api::Permissions

      graphql_name "ResultTimelineEntryMutation"
      description "A result timeline entry which includes its available mutations"

      field :result_id, ID, null: false

      field :create, Decidim::Accountability::TimelineEntryType, null: true do
        description "Add a new timeline entry to a result"

        argument :entry_date, GraphQL::Types::ISO8601Date, description: "The timeline entry date", required: true
        argument :end_date, GraphQL::Types::ISO8601Date, description: "The timeline entry end date", required: false
        argument :title, GraphQL::Types::JSON, description: "Use this to override the date of this entry", required: false
        argument :description, GraphQL::Types::JSON, description: "The timeline entry description (HTML)", required: true
      end

      field :update, Decidim::Accountability::TimelineEntryType, null: true do
        description "Add a new timeline entry to a result"

        argument :id, GraphQL::Types::ID, required: true
        argument :entry_date, GraphQL::Types::ISO8601Date, description: "The timeline entry date", required: true
        argument :end_date, GraphQL::Types::ISO8601Date, description: "The timeline entry end date", required: false
        argument :title, GraphQL::Types::JSON, description: "Use this to override the date of this entry", required: false
        argument :description, GraphQL::Types::JSON, description: "The timeline entry description (HTML)", required: true
      end

      field :destroy, Decidim::Accountability::TimelineEntryType, null: true do
        description "Destroys a timeline entry from a result"

        argument :id, GraphQL::Types::ID, "The timeline entry's id to destroy", required: true
      end

      def create(entry_date:, description:, end_date: nil, title: nil)
        enforce_permission_to :create, :timeline_entry

        form = Decidim::Accountability::Admin::TimelineEntryForm.from_params(
          "timeline_entry" => {
            "decidim_accountability_result_id" => object.id,
            "entry_date" => entry_date,
            "end_date" => end_date,
            "description" => description,
            "title" => title
          }
        ).with_context(
          current_organization: current_organization,
          current_component: object.component,
          current_user: current_user
        )

        Decidim::Accountability::Admin::CreateTimelineEntry.call(form) do
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
          I18n.t("decidim.accountability.admin.timeline_entries.create.invalid")
        )
      end

      def update(id:, entry_date:, description:, end_date: nil, title: nil)
        entry = object.timeline_entries.find_by(id: id)
        unless entry
          return GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.timeline_entries.update.invalid")
          )
        end
        enforce_permission_to :update, :timeline_entry, timeline_entry: entry

        form = Decidim::Accountability::Admin::TimelineEntryForm.from_params(
          "timeline_entry" => {
            "decidim_accountability_result_id" => entry.id,
            "entry_date" => entry_date,
            "end_date" => end_date,
            "description" => description,
            "title" => title
          }
        ).with_context(
          current_organization: current_organization,
          current_component: object.component,
          current_user: current_user
        )

        Decidim::Accountability::Admin::UpdateTimelineEntry.call(form, entry) do
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
          I18n.t("decidim.accountability.admin.timeline_entries.update.invalid")
        )
      end

      def destroy(id:)
        entry = object.timeline_entries.find_by(id: id)
        unless entry
          return GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.timeline_entries.update.invalid")
          )
        end
        enforce_permission_to :destroy, :timeline_entry, timeline_entry: entry

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
