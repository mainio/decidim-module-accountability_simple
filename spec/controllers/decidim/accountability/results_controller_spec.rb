# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    module Admin
      describe ResultsController, type: :controller do
        include Decidim::ApplicationHelper
        include Decidim::SanitizeHelper

        routes { Decidim::Accountability::AdminEngine.routes }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end
      end
    end
  end
end
