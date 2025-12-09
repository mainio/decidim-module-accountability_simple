# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class ResultMutationType < GraphQL::Schema::Object
      include Decidim::AccountabilitySimple::Api::Permissions

      implements Decidim::Apifiles::AttachableMutationsInterface
      implements Decidim::Apifiles::AttachableCollectionsMutationsInterface

      graphql_name "ResultMutation"
      description "A result which includes its available mutations"

      field :id, GraphQL::Types::ID, null: false

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

        argument :main_image, Decidim::Apifiles::FileAttributes, "The main image for the result", required: false
        argument :list_image, Decidim::Apifiles::FileAttributes, "The list image for the result", required: false

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

      field :create_link_collection, Decidim::AccountabilitySimple::ResultLinkCollectionType, null: false do
        description "Creates a link collection."

        argument :attributes, Decidim::AccountabilitySimple::ResultLinkCollectionAttributes, description: "Input attributes to create a link collection", required: true
      end

      field :update_link_collection, Decidim::AccountabilitySimple::ResultLinkCollectionType, null: false do
        description "Updates a link collection."

        argument :id, GraphQL::Types::ID, required: true
        argument :attributes, Decidim::AccountabilitySimple::ResultLinkCollectionAttributes, description: "Input attributes to update a link collection", required: true
      end

      field :delete_link_collection, Decidim::AccountabilitySimple::ResultLinkCollectionType, null: false do
        argument :id, GraphQL::Types::ID, required: true
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

      def create_link_collection(attributes:)
        enforce_permission_to :update, :result, result: object

        form = Decidim::AccountabilitySimple::Admin::ResultLinkCollectionForm.from_params(
          link_collection_params(attributes)
        ).with_context(
          current_organization: current_organization,
          current_component: object.component,
          current_user: current_user,
          result: object
        )

        link_collection = nil
        Decidim::Accountability::Admin::CreateLinkCollection.call(form) do
          on(:ok) do |collection|
            link_collection = collection
          end
        end
        return link_collection if link_collection.present?

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.accountability.admin.link_collections.create.error")
        )
      end

      def update_link_collection(id:, attributes:)
        enforce_permission_to :update, :result, result: object

        link_collection = object.result_link_collections.find_by(id: id)
        raise GraphQL::ExecutionError, "Invalid link collection ID provided: #{id}" unless link_collection

        params = link_collection_params(attributes)

        # Keep the original key through the API if the key wasn't provided
        params[:key] = link_collection.key if attributes.key.blank?

        form = Decidim::AccountabilitySimple::Admin::ResultLinkCollectionForm.from_params(params).with_context(
          current_organization: current_organization,
          current_component: object.component,
          current_user: current_user,
          result: object
        )

        status = nil
        Decidim::Accountability::Admin::UpdateLinkCollection.call(form, link_collection) do
          on(:ok) do
            status = :ok
          end
        end
        return link_collection if status == :ok

        if form.errors.any?
          return GraphQL::ExecutionError.new(
            form.errors.full_messages.join(", ")
          )
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.accountability.admin.link_collections.update.error")
        )
      end

      def delete_link_collection(id:)
        enforce_permission_to :destroy, :result, result: object

        link_collection = object.result_link_collections.find_by(id: id)
        raise GraphQL::ExecutionError, "Invalid link collection ID provided: #{id}" unless link_collection

        Decidim.traceability.perform_action!("delete", link_collection, current_user) do
          link_collection.destroy!
        end

        link_collection
      end

      protected

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def result_params(**args)
        params = {
          "id" => object.id,
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

        # Image attributes
        [:main_image, :list_image].each do |img_key|
          val = image_attributes(img_key, args)
          next if val.blank?

          params.merge!(val)
        end

        # Linked attributes
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
              "url" => linkargs[:url],
              "collection_id" => linkargs.collection&.id_value
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
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def image_attributes(image_key, attrs)
        image_attr = attrs[image_key]
        return unless image_attr
        return { "remove_#{image_key}" => true } if image_attr.remove

        { image_key.to_s => image_attr.blob } if image_attr.blob
      end

      def link_collection_params(attributes)
        {
          "position" => attributes.position,
          "key" => attributes.key,
          "name" => attributes.name
        }
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
