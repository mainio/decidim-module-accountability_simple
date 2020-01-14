# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module ResultExtensions
      extend ActiveSupport::Concern

      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections

      included do
        mount_uploader :main_image, Decidim::AccountabilitySimple::MainImageUploader
        mount_uploader :list_image, Decidim::AccountabilitySimple::ListImageUploader

        has_many :result_details, -> { order(:position) }, foreign_key: "decidim_accountability_result_id",
                                                           class_name: "Decidim::AccountabilitySimple::ResultDetail",
                                                           inverse_of: :result,
                                                           dependent: :destroy
      end
    end
  end
end
