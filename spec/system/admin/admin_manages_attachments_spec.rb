# frozen_string_literal: true

require "spec_helper"

describe "Admin manages accountability attachments", type: :system do
  include_context "when managing a component"

  let(:organization) { create(:organization) }
  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization: organization)
  end
  let(:component) { create(:component, participatory_space: participatory_process, manifest_name: "accountability") }
  let!(:result) { create(:result, component: component) }
  let(:user) { create(:user, :confirmed, :admin, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "attachments" do
    before do
      find(".icon--paperclip").click
    end

    it "shows attachments" do
      expect(page).to have_content("Attachments")
    end

    describe "create attachment", processing_uploads_for: Decidim::AttachmentUploader do
      let(:title) { ::Faker::Lorem.sentence }
      let(:description) { ::Faker::Lorem.paragraph }

      before do
        click_link "New attachment"
      end

      it "creates attachment" do
        fill_in_i18n(
          :attachment_title,
          "#attachment-title-tabs",
          en: title,
          es: title,
          ca: title
        )

        fill_in_i18n(
          :attachment_description,
          "#attachment-description-tabs",
          en: description,
          es: description,
          ca: description
        )

        attach_file(:attachment_file, Decidim::Dev.asset("city.jpeg"))
        click_button "Create attachment"
        expect(page).to have_content("Attachment created successfully")
      end
    end
  end

  describe "folders" do
    before do
      find(".icon--folder").click
    end

    it "shows attachment folders" do
      expect(page).to have_content("Attachment folders")
    end

    describe "new folder" do
      let(:title) { ::Faker::Lorem.sentence }
      let(:description) { ::Faker::Lorem.paragraph }

      before do
        click_link "New attachment collection"
      end

      it "creates new folder" do
        fill_in_i18n(
          :attachment_collection_name,
          "#attachment_collection-name-tabs",
          en: title,
          es: title,
          ca: title
        )

        fill_in_i18n(
          :attachment_collection_description,
          "#attachment_collection-description-tabs",
          en: description,
          es: description,
          ca: description
        )

        click_button "Create"
        expect(page).to have_content("Folder created successfully")
      end
    end

    describe "destroy folder" do
      let(:result) { create(:result, component: component) }
      let!(:folder) { create(:attachment_collection, collection_for: result) }

      before do
        visit current_path
      end

      it "destroys folder" do
        find(".icon--circle-x").click
        click_link "OK"
        expect(page).to have_content("Folder destroyed successfully")
      end
    end
  end
end
