# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    #
    # Decorator for user groups within the cards
    #
    class UserGroupCardPresenter < Decidim::UserGroupPresenter
      def has_tooltip?
        false
      end
    end
  end
end
