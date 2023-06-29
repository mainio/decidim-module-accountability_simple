# frozen_string_literal: true

require "spec_helper"

describe "Admin manages accountability details", type: :system do
  include_context "when managing a component"

  let(:organization) { create(:organization, available_locales: [:en, :ca, :es]) }
  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization: organization)
  end
  let!(:component) { create(:component, participatory_space: participatory_process, manifest_name: "accountability") }
  let(:user) { create(:user, :confirmed, :admin, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
    click_link "Default details"
  end

  describe "show" do
    it "shows form" do
      expect(page).to have_content("Add default detail")
    end

    context "when there is detail" do
      let(:detail_attributes) do
        {
          title: { "en" => "Some title", "ca" => "Sama kataloniaksi", "es" => "Sama espanjaksi" },
          icon: "budget",
          position: "0",
          accountability_result_detailable: component
        }
      end

      before do
        Decidim::AccountabilitySimple::ResultDetail.create(detail_attributes)
        visit current_path
      end

      it "shows detail" do
        expect(page).to have_content("Default detail #1")
        expect(find("select[id$='_icon']").value).to eq(detail_attributes[:icon])
        expect(find("input[id$='_title_en']").value).to eq(detail_attributes[:title]["en"])
      end
    end
  end

  describe "update" do
    let(:icon) { "Person" }
    let(:title_en) { ::Faker::Lorem.sentence }
    let(:title_ca) { ::Faker::Lorem.sentence }
    let(:title_es) { ::Faker::Lorem.sentence }

    it "updates default details" do
      click_button "Add default detail"

      find("select[id^='component_details_details_']").find(:option, icon).select_option
      find("input[id^='component_details_details_']").set(title_en)
      click_link "Català"
      find("input[id^='component_details_details_']").set(title_ca)
      click_link "Castellano"
      find("input[id^='component_details_details_']").set(title_es)

      click_button "Update"
      expect(page).to have_content("Default details successfully updated")
      expect(Decidim::AccountabilitySimple::ResultDetail.last.icon).to eq(icon.downcase)
      expect(Decidim::AccountabilitySimple::ResultDetail.last.title["en"]).to eq(title_en)
      expect(Decidim::AccountabilitySimple::ResultDetail.last.title["ca"]).to eq(title_ca)
      expect(Decidim::AccountabilitySimple::ResultDetail.last.title["es"]).to eq(title_es)
    end
  end
end
