# frozen_string_literal: true

require "spec_helper"

describe "Admin manages accountability", type: :system do
  include_context "when managing a component"

  let(:organization) { create(:organization) }
  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization: organization)
  end
  let!(:component) { create(:component, participatory_space: participatory_process, manifest_name: "accountability") }
  let!(:scope) { create :scope, organization: organization }
  let!(:category) { create :category, participatory_space: participatory_process }
  let(:user) { create(:user, :confirmed, :admin, organization: organization) }

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
    it "creates result" do
      click_link "New Result"

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

      scope_pick(select_data_picker(:result_decidim_scope_id), scope)
      select translated(category.name), from: :result_decidim_category_id

      attach_file(:result_main_image, Decidim::Dev.asset("city.jpeg"))
      attach_file(:result_list_image, Decidim::Dev.asset("city2.jpeg"))

      click_button "Create result"
      expect(page).to have_content("Result successfully created")
    end
  end

  context "when there is result" do
    let!(:result) { create(:result, component: component) }

    before do
      visit current_path
    end

    describe "edit result" do
      it "edits result" do
        find(".icon--pencil").click

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

        scope_pick(select_data_picker(:result_decidim_scope_id), scope)
        select translated(category.name), from: :result_decidim_category_id

        attach_file(:result_main_image, Decidim::Dev.asset("city.jpeg"))
        attach_file(:result_list_image, Decidim::Dev.asset("city2.jpeg"))

        click_button "Update result"
        expect(page).to have_content("Result successfully updated")
      end
    end

    describe "delete result" do
      it "deletes result" do
        find(".icon--circle-x").click
        click_link "OK"
        expect(page).to have_content("Result successfully deleted")
      end
    end
  end
end
