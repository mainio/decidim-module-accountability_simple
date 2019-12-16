# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module TimelineEntryFormExtensions
        extend ActiveSupport::Concern

        included do
          translatable_attribute :title, String
        end
      end
    end
  end
end
