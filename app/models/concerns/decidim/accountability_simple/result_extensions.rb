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
      end
    end
  end
end
