# frozen_string_literal: true

require "spec_helper"

describe "Admin validates result images" do # rubocop:disable RSpec/DescribeClass
  include Decidim::ComponentPathHelper

  let(:user) { create(:user, :confirmed, :admin) }

  let(:headers) { { "HOST" => user.organization.host } }

  before do
    login_as user, scope: :user
  end

  describe "POST create" do
    let(:request_path) { Decidim::Core::Engine.routes.url_helpers.upload_validations_path }

    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end

    %w(main_image list_image).each do |property|
      context "with #{property}" do
        let(:params) do
          {
            resource_class: "Decidim::Accountability::Result",
            property:,
            blob: blob.signed_id,
            form_class: "Decidim::Accountability::Admin::ResultForm"
          }
        end

        it "validates the image" do
          post(request_path, params:, headers:)

          expect(response).to have_http_status(:ok)

          messages = response.parsed_body
          expect(messages).to be_empty
        end
      end
    end
  end
end
