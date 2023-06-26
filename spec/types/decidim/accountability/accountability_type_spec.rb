# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Accountability::AccountabilityType, type: :graphql do
  include_context "with a graphql class type"

  let(:model) { create(:accountability_component) }

  describe "statuses" do
    let(:query) { "{ statuses { id } }" }

    let!(:statuses) { create_list(:status, 5, component: model) }
    let!(:other_statuses) { create_list(:status, 5, component: create(:accountability_component, organization: model.organization)) }

    it "returns the statuses for the component" do
      ids = response["statuses"].map { |node| node["id"] }
      expect(ids).to include(*statuses.map(&:id).map(&:to_s))
      expect(ids).not_to include(*other_statuses.map(&:id).map(&:to_s))
    end
  end

  describe "availableDetails" do
    let(:query) { "{ availableDetails { id } }" }

    let!(:details) { create_list(:result_detail, 3, accountability_result_detailable: model) }
    let!(:other_details) { create_list(:result_detail, 3, accountability_result_detailable: create(:accountability_component, organization: model.organization)) }

    it "returns the default details for the component" do
      ids = response["availableDetails"].map { |node| node["id"] }
      expect(ids).to include(*details.map(&:id).map(&:to_s))
      expect(ids).not_to include(*other_details.map(&:id).map(&:to_s))
    end
  end
end
