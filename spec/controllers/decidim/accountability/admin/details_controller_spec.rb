# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Admin::DetailsController, type: :controller do
  routes { Decidim::Accountability::AdminEngine.routes }

  let(:user) { create(:user, :admin, :confirmed) }

  before do
    request.env["decidim.current_organization"] = user.organization
    sign_in user
  end
end
