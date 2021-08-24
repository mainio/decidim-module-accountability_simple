# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module StatusFormExtensions
        extend ActiveSupport::Concern

        DEFAULT_COLOR = "#adadad"

        included do
          attribute :color, String, default: DEFAULT_COLOR
        end

        def map_model(_status)
          self.color ||= DEFAULT_COLOR
        end
      end
    end
  end
end
