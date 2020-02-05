# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      include Decidim::NeedsPermission

      private

      def permission_class_chain
        [
          Decidim::AccountabilitySimple::Permissions,
          Decidim::Admin::Permissions,
          Decidim::Permissions
        ]
      end

      def permission_scope
        :public
      end
    end
  end
end
