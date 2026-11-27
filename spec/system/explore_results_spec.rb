# frozen_string_literal: true

require "spec_helper"

describe "ExploreResults", versioning: true do
  include_context "with a component"

  let(:manifest_name) { "accountability" }
  let(:results_count) { 5 }
  let!(:results) do
    create_list(
      :result,
      results_count,
      component:,
      taxonomies: [taxonomy],
      published_at: Time.current
    )
  end

  let!(:root_taxonomy) { create(:taxonomy, organization: component.organization) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: component.organization) }

  let(:decidim_accountability) { Decidim::EngineRouter.main_proxy(component) }

  before do
    visit path
  end

  describe "home" do
    let(:path) { decidim_accountability.root_path }

    it "shows taxonomies and subtaxonomies with results" do
      participatory_process.taxonomies.each do |taxonomy|
        results_count = Decidim::Accountability::ResultsCalculator.new(component, taxonomy.id).count
        expect(page).to have_content(translated(taxonomy.name)) if results_count.positive?
      end
    end
  end

  describe "index" do
    let(:path) { decidim_accountability.results_path }

    it "shows all results for the given process and category" do
      within "#results" do
        results.each do |result|
          expect(page).to have_css("div#result_#{result.id}")
        end
      end

      results.each do |result|
        expect(page).to have_content(translated(result.title))
      end
    end
  end

  describe "show" do
    let(:path) { decidim_accountability.result_path(id: result.id) }
    let(:results_count) { 1 }
    let(:result) { results.first }

    it "shows all result info" do
      expect(page).to have_i18n_content(result.title)
      expect(page).to have_i18n_content(decidim_sanitize(translated_attribute(result.description)))
      expect(page).to have_content(result.reference)
      expect(page).to have_content("#{result.progress.to_i}%")
    end

    context "when result has details" do
      let(:detail_attributes) do
        {
          title: { "en" => "Some title", "ca" => "Sama katalaaniksi", "es" => "Sama espanjaksi" },
          icon: "budget",
          position: "0",
          accountability_result_detailable: result
        }
      end

      before do
        expect(page).to have_i18n_content(result.title)
        detail = Decidim::AccountabilitySimple::ResultDetail.create(detail_attributes)
        detail.values.build(result:).update!(description: { "en" => "Some value" })
        result.taxonomies = [taxonomy]
        result.save!
        visit current_path
      end

      it "shows details" do
        page.scroll_to find(".attributes")
        within ".attributes" do
          expect(page).to have_content(translated(detail_attributes[:title]))
          expect(page).to have_content("Some value")
          expect(page).to have_i18n_content(translated(taxonomy.name))
        end
      end
    end

    context "when a result has comments" do
      let(:author) { create(:user, :confirmed, organization: component.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: result) }

      before do
        expect(page).to have_i18n_content(result.title)
        visit current_path
      end

      it "shows the comments" do
        comments.each do |comment|
          expect(page).to have_i18n_content(comment.body)
        end
      end
    end
  end
end
