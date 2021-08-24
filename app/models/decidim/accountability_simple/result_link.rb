# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # Stores links related to accountability results.
    class ResultLink < Accountability::ApplicationRecord
      belongs_to :result, foreign_key: "decidim_accountability_result_id",
                          class_name: "Decidim::Accountability::Result"
    end
  end
end
