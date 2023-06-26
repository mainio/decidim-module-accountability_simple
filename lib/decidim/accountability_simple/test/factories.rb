# frozen_string_literal: true

FactoryBot.define do
  factory :result_detail, class: "Decidim::AccountabilitySimple::ResultDetail" do
    accountability_result_detailable { create(:accountability_component) }
    sequence(:position) { |n| n }
    icon { "budget" }
    title { generate_localized_title }
  end

  factory :result_detail_value, class: "Decidim::AccountabilitySimple::ResultDetailValue" do
    detail { create(:result_detail) }
    result { create(:result) }
    description { generate_localized_title }
  end

  factory :result_link, class: "Decidim::AccountabilitySimple::ResultLink" do
    result { create(:result) }
    sequence(:position) { |n| n }
    label { generate_localized_title }
    url { Decidim::Faker::Localized.localized { Faker::Internet.url } }
  end
end
