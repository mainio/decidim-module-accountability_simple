# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::AccountabilitySimple::ResultMutationType do
  include_context "with a graphql class type"
  include_context "with accountability graphql mutation"

  let(:model) { create(:result, component: component) }
  let(:component) { create(:accountability_component, participatory_space: participatory_space) }
  let(:participatory_space) { create(:participatory_process, organization: current_organization) }
  let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

  describe "update" do
    let(:default_detail) { create(:result_detail, accountability_result_detailable: component) }
    let(:status) { create(:status, component: component) }
    let(:category) { create(:category, participatory_space: participatory_space) }
    let(:scope) { create(:scope, organization: current_organization) }

    let(:title) { generate_localized_title }
    let(:summary) { generate_localized_title }
    let(:description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }

    let(:default_detail_value) { generate_localized_title }
    let(:detail_title) { generate_localized_title }
    let(:detail_value) { generate_localized_title }

    let(:link_label) { generate_localized_title }
    let(:link_url) { Decidim::Faker::Localized.localized { Faker::Internet.url } }

    let(:proposal) { create(:proposal, component: create(:proposal_component, participatory_space: participatory_space)) }
    let(:project) { create(:project, component: create(:budgets_component, participatory_space: participatory_space)) }

    let(:start_date) { Faker::Date.backward(days: 30) }
    let(:end_date) { Faker::Date.forward(days: 30) }

    let(:location) { { "address" => "Veneentekijäntie 4", "latitude" => 1.234, "longitude" => 2.345 } }

    let(:query) do
      %(
        {
          update(
            title: #{convert_value(title)},
            summary: #{convert_value(summary)},
            description: #{convert_value(description)},
            startDate: "#{start_date.to_date.iso8601}",
            endDate: "#{end_date.to_date.iso8601}",
            progress: 50,
            statusId: #{status.id},
            weight: 10,
            categoryId: #{category.id},
            scopeId: #{scope.id},
            defaultDetails: [
              {
                detailId: "#{default_detail.id}",
                description: #{convert_value(default_detail_value)}
              }
            ],
            details: [
              {
                position: 2,
                icon: "budget",
                title: #{convert_value(detail_title)}
                description: #{convert_value(detail_value)}
              }
            ],
            links: [
              {
                position: 10,
                label: #{convert_value(link_label)}
                url: #{convert_value(link_url)}
              }
            ],
            locations: [
              #{convert_value(location)}
            ],
            proposalIds: [#{proposal.id}],
            projectIds: [#{project.id}]
          ) {
            id
            title { translations { text locale } }
          }
        }
      )
    end

    it_behaves_like "when the user does not have permissions"

    it "updates the result with correct attributes" do
      expect(response["update"]["id"]).to eq(model.id.to_s)
      expect(response["update"]["title"]["translations"]).to include(
        *title.map { |locale, text| { "locale" => locale, "text" => text } }
      )

      model.reload
      expect(model.title).to include(title)
      expect(model.summary).to include(summary)
      expect(model.description).to include(description)
      expect(model.start_date).to eq(start_date)
      expect(model.end_date).to eq(end_date)
      expect(model.progress).to eq(50)
      expect(model.status).to eq(status)
      expect(model.weight).to eq(10)
      expect(model.category).to eq(category)
      expect(model.scope).to eq(scope)
      expect(model.result_default_details.first.value_for(model).description).to include(default_detail_value)
      expect(model.result_details.count).to eq(1)
      expect(model.result_details.first.title).to include(detail_title)
      expect(model.result_details.first.icon).to include("budget")
      expect(model.result_details.first.position).to eq(2)
      expect(model.result_details.first.values.first.description).to include(detail_value)
      expect(model.result_links.count).to eq(1)
      expect(model.result_links.first.position).to eq(10)
      expect(model.result_links.first.label).to include(link_label)
      expect(model.result_links.first.url).to include(link_url)
      expect(model.locations.count).to eq(1)
      expect(model.locations.first.attributes).to include(location)
      expect(model.linked_resources(:proposals, "included_proposals")).to eq([proposal])
      expect(model.linked_resources(:projects, "included_projects")).to eq([project])
    end
  end

  describe "publicity" do
    it_behaves_like "when the user does not have permissions" do
      let(:query) { "{ publicity(published: true) { id } }" }
    end

    context "when setting the result published" do
      let(:query) { "{ publicity(published: true) { id } }" }

      it "updates the published at" do
        expect(response["publicity"]["id"]).to eq(model.id.to_s)
        model.reload

        expect(model.published?).to be(true)
        expect(model.published_at).not_to be(nil)
      end
    end

    context "when setting the result unpublished" do
      let(:model) { create(:result, component: component, published_at: Time.current) }

      let(:query) { "{ publicity(published: false) { id } }" }

      it "updates the published at" do
        expect(response["publicity"]["id"]).to eq(model.id.to_s)
        model.reload

        expect(model.published?).to be(false)
        expect(model.published_at).to be(nil)
      end
    end
  end
end
