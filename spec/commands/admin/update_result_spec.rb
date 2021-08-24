# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::UpdateResult do
    subject { described_class.new(form, result) }

    let(:result) { create :result, progress: progress }
    let(:progress) { 33 }
    let(:organization) { result.component.organization }
    let(:user) { create :user, organization: organization }
    let(:form) do
      double(
        invalid?: invalid,
        organization: organization,
        title: { en: "title" },
        summary: { en: "summary" },
        description: { en: "description" },
        authors: [],
        proposal_ids: [],
        project_ids: [],
        scope: nil,
        category: nil,
        start_date: Date.yesterday,
        end_date: Date.tomorrow,
        decidim_accountability_status_id: nil,
        progress: progress,
        current_user: user,
        parent_id: nil,
        external_id: nil,
        weight: 0.3,
        theme_color: "#000000",
        use_default_details: "1",
        main_image: nil,
        list_image: nil,
        taggings: taggings_form,
        result_default_details: result_default_details ? [result_default_details] : [],
        result_details: result_details || [],
        result_links: result_links || []
      )
    end
    let(:taggings_form) do
      double(tags: tags || [])
    end
    let(:invalid) { false }
    let(:tags) {}
    let(:result_default_details) {}
    let(:result_details) {}
    let(:result_links) {}

    describe "update result and result details" do
      let(:result_details) do
        [
          double(
            id: 1337,
            icon: "person",
            title: { "en" => "This is a title", "ca" => "This is a title", "es" => "This is a title" },
            description: { "en" => "This is a description", "ca" => "This is a description", "es" => "This is a description" },
            position: 0
          )
        ]
      end

      it "updates the result and details" do
        subject.call
        expect(translated(result.title)).to eq("title")
        expect(translated(result.description)).to eq("description")
        expect(result.progress).to eq(progress)
        expect(translated(Decidim::AccountabilitySimple::ResultDetail.last.icon)).to eq("person")
        expect(translated(Decidim::AccountabilitySimple::ResultDetail.last.title)).to eq("This is a title")
        expect(translated(Decidim::AccountabilitySimple::ResultDetailValue.last.description)).to eq("This is a description")
      end
    end

    context "when there is default detail" do
      let(:detail_attributes) do
        {
          title: { "en" => "Some title", "ca" => "Sama kataloniaksi", "es" => "Sama espanjaksi" },
          icon: "budget",
          position: "0",
          accountability_result_detailable: result.component
        }
      end
      let!(:default_detail) { Decidim::AccountabilitySimple::ResultDetail.create(detail_attributes) }

      describe "update result and default detail description" do
        let(:description) { ::Faker::Lorem.paragraph }
        let(:result_default_details) do
          double(
            id: default_detail.id,
            icon: "budget",
            title: detail_attributes[:title],
            description: { "en" => description, "ca" => description, "es" => description }
          )
        end

        it "updates the result and default details description" do
          subject.call
          expect(translated(result.title)).to eq("title")
          expect(translated(result.description)).to eq("description")
          expect(result.progress).to eq(progress)
          expect(translated(Decidim::AccountabilitySimple::ResultDetailValue.last.description)).to eq(description)
        end
      end
    end
  end
end
