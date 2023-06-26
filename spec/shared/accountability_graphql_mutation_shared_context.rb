# frozen_string_literal: true

shared_context "with accountability graphql mutation" do
  def generate_localized_title
    title = super
    title.reject { |k, _v| k == "machine_translations" }
  end

  def convert_value(value)
    values = value.map do |k, v|
      val = if v.is_a?(Hash)
              convert_value(v)
            else
              v.to_json
            end

      %(#{k}: #{val})
    end.join(", ")

    "{ #{values} }"
  end
end

shared_context "when the user does not have permissions" do
  let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

  it "throws exception" do
    expect { response }.to raise_error(Decidim::AccountabilitySimple::ActionForbidden)
  end
end
