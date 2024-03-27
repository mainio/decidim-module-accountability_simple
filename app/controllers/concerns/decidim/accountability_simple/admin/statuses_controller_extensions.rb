# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module StatusesControllerExtensions
        extend ActiveSupport::Concern

        included do
          private

          # Order the statuses based on progress.
          def statuses
            @statuses ||= Decidim::Accountability::Status.where(component: current_component).order(:progress).page(params[:page]).per(15)
          end
        end
      end
    end
  end
end
