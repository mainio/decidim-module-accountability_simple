# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # Controller that allows managing all the link collections for a result.
      class LinkCollectionsController < Admin::ApplicationController
        helper_method :result

        def index
          enforce_permission_to :create, :result
        end

        def new
          enforce_permission_to :create, :result
          @form = form(AccountabilitySimple::Admin::ResultLinkCollectionForm).from_params({}, result:)
        end

        def edit
          @link_collection = collection.find(params[:id])
          enforce_permission_to :update, :result, result: @link_collection.result
          @form = form(AccountabilitySimple::Admin::ResultLinkCollectionForm).from_model(@link_collection, result:)
        end

        def create
          enforce_permission_to :create, :result
          @form = form(AccountabilitySimple::Admin::ResultLinkCollectionForm).from_params(params, result:)

          CreateLinkCollection.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("link_collections.create.success", scope: "decidim.accountability.admin")
              redirect_to action: :index
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("link_collections.create.error", scope: "decidim.accountability.admin")
              render :new
            end
          end
        end

        def update
          @link_collection = collection.find(params[:id])
          enforce_permission_to :update, :result, result: @link_collection.result
          @form = form(AccountabilitySimple::Admin::ResultLinkCollectionForm).from_params(params, result:)

          UpdateLinkCollection.call(@form, @link_collection) do
            on(:ok) do
              flash[:notice] = I18n.t("link_collections.update.success", scope: "decidim.accountability.admin")
              redirect_to action: :index
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("link_collections.update.error", scope: "decidim.accountability.admin")
              render :edit
            end
          end
        end

        def destroy
          @link_collection = collection.find(params[:id])
          enforce_permission_to :destroy, :result, result: @link_collection.result

          Decidim.traceability.perform_action!("delete", @link_collection, current_user) do
            @link_collection.destroy!
          end

          flash[:notice] = I18n.t("link_collections.destroy.success", scope: "decidim.accountability.admin")

          redirect_to action: :index
        end

        private

        def result
          @result ||= Result.where(component: current_component).find(params[:result_id])
        end

        def collection
          @collection ||= result.result_link_collections
        end
      end
    end
  end
end
