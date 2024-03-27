# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Accountability::ResultType, type: :graphql do
  include_context "with a graphql class type"

  let(:model) { create(:result, published_at: Time.current, summary: { en: "Test summary" }) }

  describe "publishedAt" do
    let(:query) { "{ publishedAt }" }

    it "returns the result's publishedAt" do
      expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
    end
  end

  describe "summary" do
    let(:query) { %({ summary { translation(locale: "en") } }) }

    it "returns the result's summary" do
      expect(response["summary"]["translation"]).to eq(model.summary["en"])
    end
  end

  describe "mainImage" do
    let(:query) { "{ mainImage }" }

    before do
      model.main_image.attach(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end

    it "returns the result's main image URL" do
      expect(response["mainImage"]).to eq(model.attached_uploader(:main_image).url)
    end
  end

  describe "mainImageBlob" do
    let(:query) { "{ mainImageBlob { id } }" }

    before do
      model.main_image.attach(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end

    it "does not return the blob for unauthorized users" do
      expect(response["mainImageBlob"]).to be_nil
    end

    context "when signed in as an admin" do
      let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

      it "returns the result's main image blob" do
        expect(response["mainImageBlob"]).to include("id" => model.main_image.blob.id.to_s)
      end
    end
  end

  describe "listImage" do
    let(:query) { "{ listImage }" }

    before do
      model.list_image.attach(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end

    it "returns the result's list image URL" do
      expect(response["listImage"]).to eq(model.attached_uploader(:list_image).url)
    end
  end

  describe "listImageBlob" do
    let(:query) { "{ listImageBlob { id } }" }

    before do
      model.list_image.attach(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end

    it "does not return the blob for unauthorized users" do
      expect(response["mainImageBlob"]).to be_nil
    end

    context "when signed in as an admin" do
      let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

      it "returns the result's list image blob" do
        expect(response["listImageBlob"]).to include("id" => model.list_image.blob.id.to_s)
      end
    end
  end

  describe "defaultDetails" do
    let(:query) { %({ defaultDetails { id values { id } } }) }

    let!(:details) { create_list(:result_detail, 3, accountability_result_detailable: model.component) }

    it "returns the result's default details" do
      ids = response["defaultDetails"].map { |item| item["id"] }
      expect(ids).to eq(details.map { |d| d.id.to_s })
    end

    it "returns an empty array for the values" do
      actual_values = response["defaultDetails"].map { |item| item["values"] }
      expect(actual_values).to eq(details.map { |_d| [] })
    end

    context "with values" do
      let!(:values) { details.map { |d| create(:result_detail_value, detail: d, result: model) } }

      it "returns the values" do
        actual_values = response["defaultDetails"].map { |item| item["values"] }
        expect(actual_values).to eq(values.map { |v| [{ "id" => v.id.to_s }] })
      end
    end

    context "with no default details" do
      let!(:details) { [] }

      it "returns an empty array" do
        expect(response["defaultDetails"]).to eq([])
      end
    end
  end

  describe "details" do
    let(:query) { %({ details { id values { id } } }) }

    let!(:details) { create_list(:result_detail, 3, accountability_result_detailable: model) }

    it "returns the result's details" do
      ids = response["details"].map { |item| item["id"] }
      expect(ids).to eq(details.map { |d| d.id.to_s })
    end

    it "returns an empty array for the values" do
      actual_values = response["details"].map { |item| item["values"] }
      expect(actual_values).to eq(details.map { |_d| [] })
    end

    context "with values" do
      let!(:values) { details.map { |d| create(:result_detail_value, detail: d, result: model) } }

      it "returns the values" do
        actual_values = response["details"].map { |item| item["values"] }
        expect(actual_values).to eq(values.map { |v| [{ "id" => v.id.to_s }] })
      end
    end

    context "with no details" do
      let!(:details) { [] }

      it "returns an empty array" do
        expect(response["details"]).to eq([])
      end
    end
  end

  describe "links" do
    let(:query) { %({ links { id } }) }

    let!(:links) { create_list(:result_link, 3, result: model) }

    it "returns the result's links" do
      ids = response["links"].map { |item| item["id"] }
      expect(ids).to eq(links.map { |d| d.id.to_s })
    end

    context "with no links" do
      let!(:links) { [] }

      it "returns an empty array" do
        expect(response["links"]).to eq([])
      end
    end
  end

  describe "linkedResources" do
    let(:query) { "{ linkedResources { __typename id } }" }

    context "without any linked resources" do
      it "returns nil" do
        expect(response["linkedResources"]).to be_nil
      end
    end

    context "with a proposal" do
      let(:proposal) { create(:proposal, component: create(:proposal_component, participatory_space: model.participatory_space)) }

      before do
        model.link_resources([proposal], "included_proposals")
      end

      it "returns the correct linked resource" do
        expect(response["linkedResources"]).to eq([{ "__typename" => "Proposal", "id" => proposal.id.to_s }])
      end
    end

    context "with a budgeting project" do
      let(:budgets_component) { create(:budgets_component, participatory_space: model.participatory_space) }
      let(:project) { create(:project, budget: create(:budget, component: budgets_component)) }

      before do
        model.link_resources([project], "included_projects")
      end

      it "returns the correct linked resource" do
        expect(response["linkedResources"]).to eq([{ "__typename" => "Project", "id" => project.id.to_s }])
      end
    end
  end

  describe "locations" do
    let(:query) { "{ locations { address latitude longitude } }" }

    let!(:location) { model.locations.create!(address: "Veneentekijäntie 4", latitude: 1.234, longitude: 2.345) }

    it "returns the correct location" do
      expect(response["locations"]).to eq([{ "address" => location.address, "latitude" => location.latitude, "longitude" => location.longitude }])
    end

    context "with no locations" do
      let!(:location) { nil }

      it "returns an empty array" do
        expect(response["locations"]).to eq([])
      end
    end
  end

  describe "tags" do
    let(:query) { %({ tags { id name { translation(locale: "en") } } }) }

    let!(:tag) { create(:tag, organization: model.organization) }
    let!(:tagging) { create(:tagging, taggable: model, tag: tag) }

    it "returns the correct location" do
      expect(response["tags"]).to eq([{ "id" => tag.id.to_s, "name" => { "translation" => tag.name["en"] } }])
    end

    context "with no tags" do
      let!(:tag) { nil }
      let!(:tagging) { nil }

      it "returns an empty array" do
        expect(response["tags"]).to eq([])
      end
    end
  end
end
