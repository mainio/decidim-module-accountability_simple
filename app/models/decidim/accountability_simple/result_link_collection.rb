# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # Stores links collections related to accountability results.
    class ResultLinkCollection < Accountability::ApplicationRecord
      belongs_to :result, foreign_key: "decidim_accountability_result_id",
                          class_name: "Decidim::Accountability::Result"
      has_many :links, foreign_key: "decidim_accountability_simple_result_link_collection_id",
                       class_name: "Decidim::AccountabilitySimple::ResultLink",
                       inverse_of: :link_collection,
                       dependent: :nullify
    end
  end
end
