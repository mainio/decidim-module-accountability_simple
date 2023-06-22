# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module TimelineEntryExtensions
      extend ActiveSupport::Concern

      def active?(at = Time.zone.now)
        return false if entry_date.blank? && end_date.blank?
        return entry_date == at.to_date if end_date.blank?
        return end_date == at.to_date if entry_date.blank?

        entry_date <= at.to_date && end_date >= at.to_date
      end
    end
  end
end
