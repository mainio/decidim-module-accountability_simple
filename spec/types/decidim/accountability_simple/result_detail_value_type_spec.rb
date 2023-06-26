# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::AccountabilitySimple::ResultDetailValueType, type: :graphql do
  include_context "with a graphql class type"

  let(:model) { create(:result_detail_value) }

  describe "id" do
    let(:query) { "{ id }" }

    it "returns the value's id" do
      expect(response["id"]).to eq(model.id.to_s)
    end
  end

  describe "detail" do
    let(:query) { "{ detail { id } }" }

    it "returns the value's detail" do
      expect(response["detail"]).to eq("id" => model.detail.id.to_s)
    end
  end

  describe "description" do
    let(:query) { "{ description { translations { locale text } } }" }

    it "returns the value's description" do
      description = model.description.reject { |locale, _text| locale == "machine_translations" }
      expect(response["description"]["translations"]).to include(
        *description.map { |locale, text| { "locale" => locale, "text" => text } }
      )
    end
  end
end
