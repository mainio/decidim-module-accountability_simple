# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        permission_action
      end
    end
  end
end
