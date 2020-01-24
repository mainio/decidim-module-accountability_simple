# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # The data store for a Result in the Decidim::Accountability component. It stores a
    # title, description and any other useful information to render a custom result.
    class ResultDetailValue < Accountability::ApplicationRecord
      belongs_to :detail, foreign_key: "decidim_accountability_result_detail_id",
                          class_name: "Decidim::AccountabilitySimple::ResultDetail",
                          inverse_of: :values
      belongs_to :result, foreign_key: "decidim_accountability_result_id",
                          class_name: "Decidim::Accountability::Result"
    end
  end
end
