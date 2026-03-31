# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module UpdateTimelineEntryExtensions
        extend ActiveSupport::Concern

        included do
          fetch_form_attributes :entry_date, :end_date, :title, :description
        end
      end
    end
  end
end
