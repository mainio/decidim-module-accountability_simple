# frozen_string_literal: true

require "spec_helper"

describe "AuthorsPickerAutocomplete" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:api_path) { "/api" }
  let(:selected) { '""' }

  before do
    final_html = html_document
    Rails.application.routes.draw do
      mount Decidim::Core::Engine => "/"
      get "test_authors_picker", to: ->(_) { [200, {}, [final_html]] }
    end
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  after do
    expect_no_js_errors

    Rails.application.reload_routes!
  end

  context "when view has the authors picker autocomplete" do
    let(:autocomplete_field) do
      %(
        <div data-autocomplete='
          {
            "name":"result[author_ids][]",
            "mode": "multi",
            "options":[],
            "placeholder":"Search for an author...",
            "selected":#{selected}
          }'
          data-autocomplete-for="author_ids" data-plugin="autocomplete">
        </div>
      )
    end

    let(:html_head) do
      %(<script>window.Decidim = { config: { get: (key) => key === "api_path" ? "#{api_path}" : null } };</script>)
    end
    let(:html_document) do
      head_extra = html_head
      body_extra = autocomplete_field
      template.instance_eval do
        <<~HTML.strip
          <!doctype html>
          <html lang="en">
          <head>
            <title>Authors Picker Test</title>
            #{stylesheet_pack_tag "decidim_core"}
            #{javascript_pack_tag "decidim_core", "decidim_admin", defer: false}
            #{head_extra}
          </head>
          <body>
            <label for="author_ids">Authors</label>
            #{body_extra}
          </body>
          </html>
        HTML
      end
    end
    let(:template_class) do
      Class.new(ActionView::Base) do
        # empty class
      end
    end
    let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }

    before do
      visit "/test_authors_picker"
    end

    describe "render autocomplete wrapper with text input" do
      it "shows multiselect" do
        within ".autoComplete_wrapper" do
          expect(page).to have_field(wait: 2)
        end
      end
    end

    context "when there are users" do
      let!(:participant) { create(:user, :confirmed, organization:, name: "Andrea Kuhlman") }
      let!(:participant2) { create(:user, :confirmed, organization:, name: "Jenae Walsh") }
      let!(:participant3) { create(:user, :confirmed, organization:, name: "John Connor") }

      describe "select one author" do
        it "shows selected author and creates hidden input" do
          find("input[type='text']").fill_in with: participant.name.slice(0..2)
          find(".autoComplete_wrapper ul#autoComplete_list_1 li", match: :first, wait: 2).click
          expect(page).to have_content(participant.name)
          hidden_input = find("input[type='hidden']", visible: false)
          expect(hidden_input.value).to eq(participant.id.to_s)
          text_input = find("input[type='text']")
          expect(text_input.value).to eq("")
        end
      end

      describe "remove selected author" do
        it "selects and removes author" do
          autocomplete_select "#{participant.name} (@#{participant.nickname})", from: :author_ids
          expect(page).to have_content(participant.name)
          expect(page).to have_css(%(input[value="#{participant.id}"]), visible: :hidden)
          find(".clear-multi-selection").click
          expect(page).to have_no_content(participant.name)
          expect(page).to have_no_css(%(input[value="#{participant.id}"]), visible: :hidden)
        end
      end

      describe "select multiple authors" do
        it "shows selected authors and creates hidden inputs" do
          autocomplete_select "#{participant.name} (@#{participant.nickname})", from: :author_ids
          autocomplete_select "#{participant2.name} (@#{participant2.nickname})", from: :author_ids
          expect(page).to have_content(participant.name)
          expect(page).to have_content(participant2.name)
          expect(page).to have_no_content(participant3.name)
          expect(page).to have_css(%(input[value="#{participant.id}"]), visible: :hidden)
          expect(page).to have_css(%(input[value="#{participant2.id}"]), visible: :hidden)
          expect(page).to have_no_css(%(input[value="#{participant3.id}"]), visible: :hidden)
        end
      end

      describe "preselected authors" do
        let(:selected) do
          %([{"value": "#{participant2.id}",
          "label": "#{participant2.name} (@#{participant2.nickname})"},
          {"value": "#{participant3.id}",
          "label": "#{participant3.name} (@#{participant3.nickname})"}])
        end

        it "shows preselected authors" do
          expect(page).to have_no_content(participant.name)
          expect(page).to have_content(participant2.name)
          expect(page).to have_content(participant3.name)
          expect(page).to have_no_css(%(input[value="#{participant.id}"]), visible: :hidden)
          expect(page).to have_css(%(input[value="#{participant2.id}"]), visible: :hidden)
          expect(page).to have_css(%(input[value="#{participant3.id}"]), visible: :hidden)
        end
      end
    end
  end
end
