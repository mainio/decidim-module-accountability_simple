# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::AccountabilitySimple::ResultLinkType, type: :graphql do
  include_context "with a graphql class type"

  let(:model) { create(:result_link) }

  describe "id" do
    let(:query) { "{ id }" }

    it "returns the link's id" do
      expect(response["id"]).to eq(model.id.to_s)
    end
  end

  describe "position" do
    let(:query) { "{ position }" }

    it "returns the link's position" do
      expect(response["position"]).to eq(model.position)
    end
  end

  describe "label" do
    let(:query) { "{ label { translations { locale text } } }" }

    it "returns the link's label" do
      label = model.label.reject { |locale, _text| locale == "machine_translations" }
      expect(response["label"]["translations"]).to include(
        *label.map { |locale, text| { "locale" => locale, "text" => text } }
      )
    end
  end

  describe "url" do
    let(:query) { "{ url { translations { locale text } } }" }

    it "returns the link's url" do
      url = model.url.reject { |locale, _text| locale == "machine_translations" }
      expect(response["url"]["translations"]).to include(
        *url.map { |locale, text| { "locale" => locale, "text" => text } }
      )
    end
  end
end
