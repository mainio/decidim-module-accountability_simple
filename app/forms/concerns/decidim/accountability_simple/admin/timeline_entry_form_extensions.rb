# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module TimelineEntryFormExtensions
        extend ActiveSupport::Concern

        included do
          translatable_attribute :title, String
          attribute :end_date, Decidim::Attributes::LocalizedDate

          # Remove the entry date presence validation
          _validators.reject! { |key, _| key == :entry_date }
          _validate_callbacks.each do |callback|
            _validate_callbacks.delete(callback) if callback.raw_filter.attributes == [:entry_date]
          end
        end
      end
    end
  end
end
