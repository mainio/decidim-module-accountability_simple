# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    #
    # Decorator for users within the cards
    #
    class UserCardPresenter < Decidim::UserPresenter
      def has_tooltip?
        false
      end
    end
  end
end
