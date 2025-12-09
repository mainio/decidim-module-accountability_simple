# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module TimelineEntryFormExtensions
        extend ActiveSupport::Concern

        included do
          attribute :end_date, Decidim::Attributes::LocalizedDate

          # Remove the title and entry date presence validations
          #
          # NOTE: Title became a required field in core but since there are
          # legacy integrations, we need to keep it optional.
          [:entry_date, :title].each do |attr|
            _validators.reject! { |key, _| key == attr }
            _validate_callbacks.each do |callback|
              _validate_callbacks.delete(callback) if callback.raw_filter.attributes == [attr]
            end
          end
        end
      end
    end
  end
end
