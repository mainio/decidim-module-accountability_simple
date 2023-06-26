# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Api
      module ResourceLinkTypeExtensions
        def self.included(type)
          type.implements Decidim::AccountabilitySimple::ResourceLinkInterface
        end
      end
    end
  end
end
