# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::AccountabilitySimple::ResultDetailType, type: :graphql do
  include_context "with a graphql class type"

  let(:model) { create(:result_detail) }

  describe "id" do
    let(:query) { "{ id }" }

    it "returns the result detail's id" do
      expect(response["id"]).to eq(model.id.to_s)
    end
  end

  describe "position" do
    let(:query) { "{ position }" }

    it "returns the result detail's position" do
      expect(response["position"]).to eq(model.position)
    end
  end

  describe "title" do
    let(:query) { "{ title { translations { locale text } } }" }

    it "returns the result detail's title" do
      title = model.title.reject { |locale, _text| locale == "machine_translations" }
      expect(response["title"]["translations"]).to include(
        *title.map { |locale, text| { "locale" => locale, "text" => text } }
      )
    end
  end

  describe "icon" do
    let(:query) { "{ icon }" }

    it "returns the result detail's icon" do
      expect(response["icon"]).to eq(model.icon)
    end
  end

  describe "values" do
    let(:query) { "{ values { id } }" }

    context "without any values" do
      it "returns an empty array" do
        expect(response["values"]).to eq([])
      end
    end

    context "with values" do
      let(:results) { create_list(:result, 3, component: model.accountability_result_detailable) }

      context "with component as detailable" do
        let!(:values) { results.map { |r| create(:result_detail_value, detail: model, result: r) } }

        it "returns all values" do
          expect(response["values"]).to eq(values.map { |v| { "id" => v.id.to_s } })
        end
      end

      context "with result as detailable" do
        let(:model) { create(:result_detail, accountability_result_detailable: result) }
        let(:result) { create(:result) }
        let!(:value) { create(:result_detail_value, detail: model, result: result) }

        let!(:another_result) { create(:result, component: result.component) }
        let!(:another_value) { create(:result_detail_value, detail: model, result: another_result) }

        # Pass the correct context through instrumenter since the query is made
        # directly against the result detail record.
        let(:instrumenter) do
          (
            Module.new do
              module_function

              def before_query(query)
                query.context.scoped_context[:parent] = result
              end

              def after_query(_query); end
            end
          ).tap do |mod|
            allow(mod).to receive(:result).and_return(result)
          end
        end

        before do
          schema.instrument(:query, instrumenter)
        end

        it "returns values for the result" do
          expect(response["values"]).to eq([{ "id" => value.id.to_s }])
        end
      end
    end
  end
end
