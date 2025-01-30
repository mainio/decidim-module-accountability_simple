# frozen_string_literal: true

require "spec_helper"

describe "AdminManagesAccountability" do
  include_context "when managing a component"

  let(:organization) { create(:organization, available_locales: [:en, :ca, :es]) }
  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization:)
  end
  let!(:component) { create(:component, participatory_space: participatory_process, manifest_name: "accountability") }
  let!(:scope) { create(:scope, organization:) }
  let!(:category) { create(:category, participatory_space: participatory_process) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "result page" do
    it "shows results" do
      expect(page).to have_content("Results")
    end
  end

  describe "create result" do
    let(:icon) { "Voting" }
    let(:detail_title) { Faker::Lorem.sentence }
    let(:detail_description) { Faker::Lorem.sentence }

    it "creates result" do
      click_on "New result"

      fill_in_i18n(
        :result_title,
        "#result-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      fill_in_i18n(
        :result_title,
        "#result-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      fill_in_i18n_editor(
        :result_description,
        "#result-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      select translated(scope.name), from: :result_decidim_scope_id
      select translated(category.name), from: :result_decidim_category_id

      dynamically_attach_file(:result_main_image, Decidim::Dev.asset("city.jpeg"))
      dynamically_attach_file(:result_list_image, Decidim::Dev.asset("city2.jpeg"))

      click_on "Add detail"
      within ".result-detail-item" do
        find("select[id^='result_result_details_']").find(:option, icon).select_option
        find("input[id$='_title_en']").set(detail_title)
        find("input[id$='_description_en']").set(detail_title)
      end

      click_on "Create result"
      expect(page).to have_content("Result successfully created")
    end
  end

  context "when there is a result" do
    let!(:result) { create(:result, component:) }

    before do
      visit current_path
    end

    describe "edit result" do
      it "edits result" do
        find(".action-icon--edit").click

        fill_in_i18n(
          :result_title,
          "#result-title-tabs",
          en: "My new title",
          es: "Mi nuevo título",
          ca: "El meu nou títol"
        )

        fill_in_i18n(
          :result_title,
          "#result-title-tabs",
          en: "My new title",
          es: "Mi nuevo título",
          ca: "El meu nou títol"
        )

        fill_in_i18n_editor(
          :result_description,
          "#result-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        select translated(scope.name), from: :result_decidim_scope_id
        select translated(category.name), from: :result_decidim_category_id

        dynamically_attach_file(:result_main_image, Decidim::Dev.asset("city.jpeg"))
        dynamically_attach_file(:result_list_image, Decidim::Dev.asset("city2.jpeg"))

        click_on "Update result"
        expect(page).to have_content("Result successfully updated")
      end
    end

    describe "delete result" do
      it "deletes result" do
        find(".action-icon--remove").click
        click_on "OK"
        expect(page).to have_content("Result successfully deleted")
      end
    end
  end
end
