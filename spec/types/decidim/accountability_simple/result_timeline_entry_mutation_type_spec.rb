# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::AccountabilitySimple::ResultTimelineEntryMutationType do
  include_context "with a graphql class type"
  include_context "with accountability graphql mutation"

  let(:model) { create(:result, component: component) }
  let(:component) { create(:accountability_component, participatory_space: participatory_space) }
  let(:participatory_space) { create(:participatory_process, organization: current_organization) }
  let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

  let(:title) { generate_localized_title }
  let(:description) { generate_localized_title }
  let(:entry_date) { Faker::Date.backward(days: 30) }
  let(:end_date) { Faker::Date.forward(days: 30) }

  describe "create" do
    let(:query) do
      %(
        {
          create(
            title: #{convert_value(title)},
            description: #{convert_value(description)},
            entryDate: "#{entry_date.to_date.iso8601}",
            endDate: "#{end_date.to_date.iso8601}"
          ) { id }
        }
      )
    end

    it_behaves_like "when the user does not have permissions"

    it "creates a new timeline entry" do
      expect { response }.to change(Decidim::Accountability::TimelineEntry, :count).by(1)

      expect(response["create"]["id"]).to match(/[0-9]+/)

      model.reload
      expect(model.timeline_entries.first.title).to eq(title)
      expect(model.timeline_entries.first.description).to eq(description)
      expect(model.timeline_entries.first.entry_date).to eq(entry_date)
      expect(model.timeline_entries.first.end_date).to eq(end_date)
    end

    # Note that this is important for backwards compatibility because some of
    # the legacy integration apps are relying on creating the entries without
    # titles.
    context "without a title" do
      let(:query) do
        %(
          {
            create(
              description: #{convert_value(description)},
              entryDate: "#{entry_date.to_date.iso8601}",
              endDate: "#{end_date.to_date.iso8601}"
            ) { id }
          }
        )
      end

      it "creates a new timeline entry" do
        expect { response }.to change(Decidim::Accountability::TimelineEntry, :count).by(1)

        expect(response["create"]["id"]).to match(/[0-9]+/)

        model.reload
        expect(model.timeline_entries.first.description).to eq(description)
        expect(model.timeline_entries.first.entry_date).to eq(entry_date)
        expect(model.timeline_entries.first.end_date).to eq(end_date)
      end
    end
  end

  describe "update" do
    let!(:entry) { create(:timeline_entry, result: model) }

    let(:query) do
      %(
        {
          update(
            id: "#{entry.id}",
            title: #{convert_value(title)},
            description: #{convert_value(description)},
            entryDate: "#{entry_date.to_date.iso8601}",
            endDate: "#{end_date.to_date.iso8601}"
          ) { id }
        }
      )
    end

    it_behaves_like "when the user does not have permissions"

    it "updates the timeline entry" do
      expect { response }.not_to change(Decidim::Accountability::TimelineEntry, :count)

      expect(response["update"]["id"]).to eq(entry.id.to_s)

      entry.reload
      expect(entry.title).to include(title)
      expect(entry.description).to include(description)
      expect(entry.entry_date).to eq(entry_date)
      expect(entry.end_date).to eq(end_date)
    end

    # Note that this is important for backwards compatibility because some of
    # the legacy integration apps are relying on creating the entries without
    # titles.
    context "without a title" do
      let(:query) do
        %(
          {
            update(
              id: "#{entry.id}",
              description: #{convert_value(description)},
              entryDate: "#{entry_date.to_date.iso8601}",
              endDate: "#{end_date.to_date.iso8601}"
            ) { id }
          }
        )
      end

      it "creates a new timeline entry" do
        expect { response }.not_to change(Decidim::Accountability::TimelineEntry, :count)

        expect(response["update"]["id"]).to eq(entry.id.to_s)

        entry.reload
        expect(entry.title).to match("machine_translations" => instance_of(Hash))
        expect(entry.description).to include(description)
        expect(entry.entry_date).to eq(entry_date)
        expect(entry.end_date).to eq(end_date)
      end
    end
  end

  describe "destroy" do
    let!(:entry) { create(:timeline_entry, result: model) }

    let(:query) { %({ destroy(id: "#{entry.id}") { id } }) }

    it_behaves_like "when the user does not have permissions"

    it "destroys the timeline entry" do
      expect { response }.to change(Decidim::Accountability::TimelineEntry, :count).by(-1)

      expect(response["destroy"]["id"]).to match(entry.id.to_s)
    end
  end
end
