# frozen_string_literal: true

require "spec_helper"

describe "Explore results", versioning: true, type: :system do
  include_context "with a component"

  let(:manifest_name) { "accountability" }
  let(:results_count) { 5 }
  let!(:scope) { create :scope, organization: component.organization }
  let!(:results) do
    create_list(
      :result,
      results_count,
      component: component,
      published_at: Time.current
    )
  end

  let(:decidim_accountability) { Decidim::EngineRouter.main_proxy(component) }

  before do
    component.update(settings: { scopes_enabled: true })
    visit path
  end

  describe "home" do
    let(:path) { decidim_accountability.root_path }

    it "shows categories and subcategories with results" do
      participatory_process.categories.each do |category|
        results_count = Decidim::Accountability::ResultsCalculator.new(component, nil, category.id).count
        expect(page).to have_content(translated(category.name)) if !category.subcategories.empty? || results_count.positive?
      end
    end
  end

  describe "index" do
    let(:path) { decidim_accountability.results_path }

    it "shows all results for the given process and category" do
      expect(page).to have_selector(".card--result", count: results_count)

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
      expect(page).to have_i18n_content(result.description)
      expect(page).to have_content(result.reference)
      expect(page).to have_content("#{result.progress.to_i}%")
    end

    context "when result has details" do
      let(:scope) { create :scope, organization: organization }
      let(:category) { create :category, participatory_space: participatory_process }
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
        detail.values.build(result: result).update!(description: { "en" => "Some value" })
        result.scope = scope
        result.category = category
        result.save!
        visit current_path
      end

      it "shows details" do
        page.scroll_to find(".line-stats-project")
        within ".line-stats-project" do
          expect(page).to have_content(translated(detail_attributes[:title]))
          expect(page).to have_content("Some value")
          expect(page).to have_i18n_content(scope.name)
          expect(page).to have_i18n_content(category.name)
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
