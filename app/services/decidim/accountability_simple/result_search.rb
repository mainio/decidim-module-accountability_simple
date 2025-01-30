# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # Implements the custom search functionality for results.
    class ResultSearch < ResourceSearch
      def build(params)
        add_scope(:user_favorites, user) if user && params[:favorites] == "1"

        super(params)
      end
    end
  end
end
