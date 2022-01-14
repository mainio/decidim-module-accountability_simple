# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultMutationType < GraphQL::Schema::Object
      include Decidim::AccountabilitySimple::Api::Permissions

      graphql_name "ResultMutation"
      description "A result which includes its available mutations"

      field :id, ID, null: false

      field :update, Decidim::Accountability::ResultType, null: true do
        description "The content mutations to be updated."

        argument :title, GraphQL::Types::JSON, description: "The result title localized hash, e.g. {\"en\": \"English title\"}", required: true
        argument :summary, GraphQL::Types::JSON, description: "The result summary localized hash, e.g. {\"en\": \"English summary\"}", required: true
        argument :description, GraphQL::Types::JSON, description: "The result description localized hash (HTML), e.g. {\"en\": \"<p>English description</p>\"}", required: true
        argument :start_date, GraphQL::Types::ISO8601DateTime, description: "The result start date", required: false
        argument :end_date, GraphQL::Types::ISO8601DateTime, description: "The result end date", required: false
        argument :progress, GraphQL::Types::Float, description: "The result progress percentage", required: true
        argument :status_id, GraphQL::Types::Int, description: "The result status ID", required: false
        argument :weight, GraphQL::Types::Float, description: "The weight (order) of the result", required: false

        argument :category_id, GraphQL::Types::Int, description: "The result category ID", required: false
        argument :scope_id, GraphQL::Types::Int, description: "The result scope ID", required: false

        argument :default_details, [Decidim::AccountabilitySimple::ResultDefaultDetailAttributes], required: false
        argument :details, [Decidim::AccountabilitySimple::ResultDetailAttributes], required: false
        argument :links, [Decidim::AccountabilitySimple::ResultLinkAttributes], required: false
        argument :locations, [Decidim::Locations::LocationAttributes], required: false

        # Linked resources
        argument :proposal_ids, [GraphQL::Types::Int], description: "The linked proposal IDs for the result", required: false
        argument :idea_ids, [GraphQL::Types::Int], description: "The linked idea IDs for the result", required: false
        argument :plan_ids, [GraphQL::Types::Int], description: "The linked plan IDs for the result", required: false
        argument :project_ids, [GraphQL::Types::Int], description: "The linked project IDs for the result", required: false
      end

      field :publicity, Decidim::Accountability::ResultType, null: true do
        description "The publicity mutation to set the record published or unpublished."

        argument :published, GraphQL::Types::Boolean, description: "Set the record published (true) or unpublished (false)", required: true
      end

      def update(**args)
        enforce_permission_to :update, :result, result: object

        form = Decidim::Accountability::Admin::ResultForm.from_params(
          "result" => result_params(**args)
        ).with_context(
          current_organization: current_organization,
          current_component: object.component,
          current_user: current_user
        )

        result = object
        Decidim::Accountability::Admin::UpdateResult.call(form, result) do
          on(:ok) do
            return result
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.accountability.admin.results.update.invalid")
        )
      end

      def publicity(published:)
        enforce_permission_to :update, :result, result: object

        if published
          Decidim::Accountability::Admin::PublishResult.call(object, current_user) do
            on(:ok) do
              return result
            end
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.results.publish.invalid")
          )
        else
          Decidim::Accountability::Admin::UnpublishResult.call(object, current_user) do
            on(:ok) do
              return result
            end
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.accountability.admin.results.unpublish.invalid")
          )
        end
      end

      protected

      def result_params(**args)
        params = {
          "weight" => args[:weight] || object.weight,
          "title" => args[:title],
          "decidim_category_id" => args[:category_id],
          "decidim_scope_id" => args[:scope_id],
          "summary" => args[:summary],
          "description" => args[:description],
          "progress" => args[:progress] || object.progress,
          "decidim_accountability_status_id" => args[:status_id] || object.status&.id,
          "start_date" => args[:start_date],
          "end_date" => args[:end_date],
          "proposal_ids" => args[:proposal_ids],
          "idea_ids" => args[:idea_ids],
          "plan_ids" => args[:plan_ids],
          "project_ids" => args[:project_ids]
        }
        if args[:default_details]
          params["result_default_details"] = args[:default_details].map do |detargs|
            { "id" => detargs[:detail_id], "description" => detargs[:description] }
          end
        end
        if args[:details]
          details = args[:details].map do |detargs|
            {
              "id" => detargs[:detail_id],
              "position" => detargs[:position],
              "icon" => detargs[:icon],
              "title" => detargs[:title],
              "description" => detargs[:description]
            }
          end
          deleted_details = object.result_details.where.not(
            id: details.map { |d| d["id"] }
          ).map do |det|
            {
              "id" => det.id,
              "deleted" => true
            }
          end

          params["result_details"] = details + deleted_details
        end
        if args[:links]
          links = args[:links].map do |linkargs|
            {
              "id" => linkargs[:id],
              "position" => linkargs[:position],
              "label" => linkargs[:label],
              "url" => linkargs[:url]
            }
          end
          deleted_links = object.result_links.where.not(
            id: links.map { |l| l["id"] }
          ).map do |link|
            {
              "id" => link.id,
              "deleted" => true
            }
          end

          params["result_links"] = links + deleted_links
        end
        if args[:locations]
          params["locations"] = args[:locations].map do |locargs|
            {
              "id" => locargs[:id],
              "address" => locargs[:address],
              "latitude" => locargs[:latitude],
              "longitude" => locargs[:longitude]
            }
          end
        end

        params
      end

      private

      def current_organization
        context[:current_organization]
      end

      def current_user
        context[:current_user]
      end

      def geocoder
        return unless Decidim::Map.available?(:geocoding)

        @geocoder ||= Decidim::Map.geocoding(
          organization: context[:current_organization]
        )
      end
    end
  end
end
