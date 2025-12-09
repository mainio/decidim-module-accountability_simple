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

    context "with main image" do
      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city.jpeg")),
          filename: "city.jpeg",
          content_type: "image/jpeg"
        )
      end
      let(:query) do
        %(
          {
            update(
              title: #{convert_value(title)},
              summary: #{convert_value(summary)},
              description: #{convert_value(description)},
              progress: 50,
              mainImage: { blobId: #{blob.id} }
            ) { id }
          }
        )
      end

      it "sets the main image" do
        response
        model.reload
        expect(model.main_image.blob).to eq(blob)
      end

      context "when removing the image" do
        let(:query) do
          %(
            {
              update(
                title: #{convert_value(title)},
                summary: #{convert_value(summary)},
                description: #{convert_value(description)},
                progress: 50,
                mainImage: { remove: true }
              ) { id }
            }
          )
        end

        before { model.main_image.attach(blob) }

        it "removes the blob attachment and destroys the blob" do
          expect(model.main_image.attached?).to be(true)
          response
          model.reload
          expect(model.main_image.attached?).to be(false)
        end
      end
    end

    context "with list image" do
      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city.jpeg")),
          filename: "city.jpeg",
          content_type: "image/jpeg"
        )
      end
      let(:query) do
        %(
          {
            update(
              title: #{convert_value(title)},
              summary: #{convert_value(summary)},
              description: #{convert_value(description)},
              progress: 50,
              listImage: { blobId: #{blob.id} }
            ) { id }
          }
        )
      end

      it "sets the list image" do
        response
        model.reload
        expect(model.list_image.blob).to eq(blob)
      end

      context "when removing the image" do
        let(:query) do
          %(
            {
              update(
                title: #{convert_value(title)},
                summary: #{convert_value(summary)},
                description: #{convert_value(description)},
                progress: 50,
                listImage: { remove: true }
              ) { id }
            }
          )
        end

        before { model.list_image.attach(blob) }

        it "removes the blob attachment and destroys the blob" do
          expect(model.list_image.attached?).to be(true)
          response
          model.reload
          expect(model.list_image.attached?).to be(false)
        end
      end
    end

    context "with links" do
      let(:query) do
        %(
          {
            update(
              title: #{convert_value(title)},
              summary: #{convert_value(summary)},
              description: #{convert_value(description)},
              progress: 50,
              links: [
                {
                  position: 10,
                  label: #{convert_value(link_label)}
                  url: #{convert_value(link_url)}
                }
              ]
            ) { id }
          }
        )
      end

      it "creates the links" do
        expect { response }.to change(Decidim::AccountabilitySimple::ResultLink, :count).by(1)
        model.reload
        expect(model.result_links.count).to eq(1)

        link = model.result_links.first
        expect(link.position).to eq(10)
        expect(link.label).to eq(link_label)
        expect(link.url).to eq(link_url)
        expect(link.link_collection).to be_nil
      end
    end

    context "with link collections" do
      let(:link_collection) do
        model.result_link_collections.create!(
          key: "testing",
          name: generate_localized_title,
          position: 0
        )
      end
      let(:query) do
        %(
          {
            update(
              title: #{convert_value(title)},
              summary: #{convert_value(summary)},
              description: #{convert_value(description)},
              progress: 50,
              links: [
                {
                  position: 10,
                  label: #{convert_value(link_label)}
                  url: #{convert_value(link_url)}
                  collection: { key: "#{link_collection.key}" }
                }
              ]
            ) { id }
          }
        )
      end

      it "maps the link with the collection" do
        expect { response }.to change(Decidim::AccountabilitySimple::ResultLink, :count).by(1)
        model.reload
        expect(model.result_links.count).to eq(1)

        link = model.result_links.first
        expect(link.link_collection).to eq(link_collection)
      end

      context "when using the collection ID" do
        let(:query) do
          %(
            {
              update(
                title: #{convert_value(title)},
                summary: #{convert_value(summary)},
                description: #{convert_value(description)},
                progress: 50,
                links: [
                  {
                    position: 10,
                    label: #{convert_value(link_label)}
                    url: #{convert_value(link_url)}
                    collection: { id: "#{link_collection.id}" }
                  }
                ]
              ) { id }
            }
          )
        end

        it "maps the link with the collection" do
          expect { response }.to change(Decidim::AccountabilitySimple::ResultLink, :count).by(1)
          model.reload
          expect(model.result_links.count).to eq(1)
          expect(model.result_links.first.link_collection).to eq(link_collection)
        end
      end
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
        expect(model.published_at).not_to be_nil
      end
    end

    context "when setting the result unpublished" do
      let(:model) { create(:result, component: component, published_at: Time.current) }

      let(:query) { "{ publicity(published: false) { id } }" }

      it "updates the published at" do
        expect(response["publicity"]["id"]).to eq(model.id.to_s)
        model.reload

        expect(model.published?).to be(false)
        expect(model.published_at).to be_nil
      end
    end
  end

  describe "createLinkCollection" do
    let(:query) do
      %(
        {
          createLinkCollection(
            attributes: {
              position: #{position},
              key: "#{key}",
              name: #{convert_value(name)}
            }
          ) { id }
        }
      )
    end
    let(:position) { 123 }
    let(:key) { "testing" }
    let(:name) { generate_localized_title }

    it_behaves_like "when the user does not have permissions"

    it "creates a new link collection" do
      expect { response }.to change(Decidim::AccountabilitySimple::ResultLinkCollection, :count).by(1)
    end

    it "sets the correct details for the collection" do
      collection = Decidim::AccountabilitySimple::ResultLinkCollection.find(response["createLinkCollection"]["id"])
      expect(collection.result).to eq(model)
      expect(collection.position).to eq(position)
      expect(collection.key).to eq(key)
      expect(collection.name).to eq(name)
    end
  end

  describe "updateLinkCollection" do
    let!(:collection) do
      model.result_link_collections.create!(
        position: 0,
        key: "original",
        name: generate_localized_title
      )
    end
    let(:query) do
      %(
        {
          updateLinkCollection(
            id: "#{collection.id}",
            attributes: {
              position: #{position},
              key: "#{key}",
              name: #{convert_value(name)}
            }
          ) { id }
        }
      )
    end
    let(:position) { 123 }
    let(:key) { "testing" }
    let(:name) { generate_localized_title }

    it_behaves_like "when the user does not have permissions"

    it "updates the correct details for the collection" do
      expect(response["updateLinkCollection"]["id"]).to eq(collection.id.to_s)

      collection.reload
      expect(collection.position).to eq(position)
      expect(collection.key).to eq(key)
      expect(collection.name).to eq(name)
    end
  end

  describe "deleteLinkCollection" do
    let!(:collection) do
      model.result_link_collections.create!(
        position: 0,
        key: "original",
        name: generate_localized_title
      )
    end
    let(:query) do
      %({ deleteLinkCollection(id: "#{collection.id}") { id } })
    end

    it_behaves_like "when the user does not have permissions"

    it "creates an action log record" do
      expect { response }.to change(Decidim::ActionLog, :count).by(1)
    end

    it "deletes the collection" do
      expect { response }.to change(Decidim::AccountabilitySimple::ResultLinkCollection, :count).by(-1)
    end
  end
end
