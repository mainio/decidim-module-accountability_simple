# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Accountability::TimelineEntryType, type: :graphql do
  include_context "with a graphql class type"

  let(:model) { create(:timeline_entry, title: generate_localized_title, end_date: Time.current) }

  describe "title" do
    let(:query) { %({ title { translation(locale: "en") } }) }

    it "returns the timeline entry's title" do
      expect(response["title"]["translation"]).to eq(model.title["en"])
    end
  end

  describe "endDate" do
    let(:query) { "{ endDate }" }

    it "returns the timeline entry's endDate" do
      expect(response["endDate"]).to eq(model.end_date.to_date.iso8601)
    end
  end
end
