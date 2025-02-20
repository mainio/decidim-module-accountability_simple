# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class ResultsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::SanitizeHelper
        include Decidim::Accountability::Admin::Filterable

        helper_method :results, :parent_result, :parent_results, :statuses, :present, :blank_result_detail, :blank_result_link

        def collection
          parent_id = params[:parent_id].presence
          @collection ||= Result.where(component: current_component, parent_id:).page(params[:page]).per(15)
        end

        def new
          enforce_permission_to :create, :result

          # Pass the component
          @form = form(ResultForm).from_model(Result.new(component: current_component))
          @form.parent_id = params[:parent_id]
        end

        def edit
          enforce_permission_to(:update, :result, result:)

          @form = form(ResultForm).from_model(result)
        end

        def create
          enforce_permission_to :create, :result

          @form = form(ResultForm).from_params(params)

          CreateResult.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("results.create.success", scope: "decidim.accountability.admin")
              redirect_to results_path(parent_id: result.parent_id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("results.create.invalid", scope: "decidim.accountability.admin")
              render action: "new"
            end
          end
        end

        def update
          enforce_permission_to(:update, :result, result:)

          @form = form(ResultForm).from_params(params)

          UpdateResult.call(@form, result) do
            on(:ok) do
              flash[:notice] = I18n.t("results.update.success", scope: "decidim.accountability.admin")
              redirect_to results_path(parent_id: result.parent_id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("results.update.invalid", scope: "decidim.accountability.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :result, result:)

          DestroyResult.call(result, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("results.destroy.success", scope: "decidim.accountability.admin")

              redirect_to results_path(parent_id: result.parent_id)
            end
          end
        end

        def publish
          enforce_permission_to(:update, :result, result:)

          PublishResult.call(result, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("results.publish.success", scope: "decidim.accountability.admin")
              redirect_to action: :index
            end
            on(:invalid) do
              flash[:alert] = I18n.t("results.publish.invalid", scope: "decidim.accountability.admin")
              redirect_to action: :index
            end
          end
        end

        def unpublish
          enforce_permission_to(:update, :result, result:)

          UnpublishResult.call(result, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("results.unpublish.success", scope: "decidim.accountability.admin")
              redirect_to action: :index
            end
            on(:invalid) do
              flash[:alert] = I18n.t("results.unpublish.invalid", scope: "decidim.accountability.admin")
              redirect_to action: :index
            end
          end
        end

        private

        def results
          parent_id = params[:parent_id].presence
          @results ||= Result.where(component: current_component, parent_id:).page(params[:page]).per(15)
        end

        def result
          @result ||= Result.where(component: current_component).find(params[:id])
        end

        def parent_result
          @parent_result ||= Result.find_by(component: current_component, id: params[:parent_id])
        end

        def parent_results
          @parent_results ||= Result.where(component: current_component, parent_id: nil)
        end

        def statuses
          @statuses ||= Status.where(component: current_component)
        end

        def blank_result_detail
          @blank_result_detail ||= Decidim::AccountabilitySimple::Admin::ResultDetailsForm.new
        end

        def blank_result_link
          @blank_result_link ||= Decidim::AccountabilitySimple::Admin::ResultLinkForm.new
        end
      end
    end
  end
end
