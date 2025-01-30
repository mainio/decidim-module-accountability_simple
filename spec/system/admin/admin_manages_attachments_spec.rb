# frozen_string_literal: true

require "spec_helper"

describe "AdminManagesAccountabilityAttachments" do
  include_context "when managing a component"

  let(:organization) { create(:organization, available_locales: [:en, :ca, :es]) }
  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization:)
  end
  let(:component) { create(:component, participatory_space: participatory_process, manifest_name: "accountability") }
  let!(:result) { create(:result, component:) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "attachments" do
    before do
      find(".action-icon--attachments").click
    end

    it "shows attachments" do
      expect(page).to have_content("Attachments")
    end

    describe "create attachment", processing_uploads_for: Decidim::AttachmentUploader do
      let(:title) { Faker::Lorem.sentence }
      let(:description) { Faker::Lorem.paragraph }

      before do
        click_on "New attachment"
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

        dynamically_attach_file(:attachment_file, Decidim::Dev.asset("city.jpeg"))
        click_on "Create attachment"
        expect(page).to have_content("Attachment created successfully")
      end
    end
  end

  describe "folders" do
    before do
      find(".action-icon--attachment_collections").click
    end

    it "shows attachment folders" do
      expect(page).to have_content("Attachment folders")
    end

    describe "new folder" do
      let(:title) { Faker::Lorem.sentence }
      let(:description) { Faker::Lorem.paragraph }

      before do
        click_on "New attachment folder"
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

        click_on "Create"
        expect(page).to have_content("Folder created successfully")
      end
    end

    describe "destroy folder" do
      let(:result) { create(:result, component:) }
      let!(:folder) { create(:attachment_collection, collection_for: result) }

      before do
        visit current_path
      end

      it "destroys folder" do
        find(".action-icon--remove").click
        click_on "OK"
        expect(page).to have_content("Folder destroyed successfully")
      end
    end
  end
end
