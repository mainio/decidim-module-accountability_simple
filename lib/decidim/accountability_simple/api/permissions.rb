# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Api
      module Permissions
        extend ActiveSupport::Concern

        private

        def enforce_permission_to(action, subject, extra_context = {})
          raise Decidim::AccountabilitySimple::ActionForbidden unless allowed_to?(action, subject, extra_context)
        end

        def allowed_to?(action, subject, extra_context = {}, user = current_user)
          scope ||= :admin
          permission_action = Decidim::PermissionAction.new(scope: scope, action: action, subject: subject)

          permission_class_chain.inject(permission_action) do |current_permission_action, permission_class|
            permission_class.new(
              user,
              current_permission_action,
              permissions_context.merge(extra_context)
            ).permissions
          end.allowed?
        rescue Decidim::PermissionAction::PermissionNotSetError
          false
        end

        def permission_class_chain
          [
            object.component.manifest.permissions_class,
            object.participatory_space.manifest.permissions_class,
            ::Decidim::Admin::Permissions,
            ::Decidim::Permissions
          ]
        end

        def permissions_context
          {
            current_settings: object.component.current_settings,
            component_settings: object.component.settings,
            current_organization: object.organization,
            current_component: object.component
          }
        end

        class ::Decidim::AccountabilitySimple::ActionForbidden < StandardError
        end
      end
    end
  end
end
