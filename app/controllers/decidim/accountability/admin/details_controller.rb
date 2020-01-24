# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage results from a Participatory Process
      class DetailsController < Admin::ApplicationController
        helper_method :details, :blank_detail

        def show
          enforce_permission_to :create, :result

          @form = form(Decidim::AccountabilitySimple::Admin::ComponentDetailsForm).from_model(current_component)
        end

        def update
          enforce_permission_to :create, :result

          @form = form(Decidim::AccountabilitySimple::Admin::ComponentDetailsForm).from_params(params)

          Decidim::AccountabilitySimple::Admin::UpdateDefaultDetails.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("details.update.success", scope: "decidim.accountability.admin")
              redirect_to results_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("details.update.invalid", scope: "decidim.accountability.admin")
              render action: "index"
            end
          end
        end

        private

        def details
          @details ||= Decidim::AccountabilitySimple::ResultDetail.where(
            accountability_result_detailable: current_component
          )
        end

        def blank_detail
          @blank_detail ||= Decidim::AccountabilitySimple::Admin::DefaultDetailsForm.new
        end
      end
    end
  end
end
