# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module ScopesHelperExtensions
      def scope_picker_options(scopes, selected = nil)
        groups = []
        without_groups = []
        scopes.each do |scope|
          name = translated_attribute(scope.name)

          if scope.children.any?
            groups << [name, scope_picker_options(scope.children)]
          else
            without_groups << [name, scope.id]
          end
        end

        return options_for_select(without_groups, selected) if groups.empty?

        unless without_groups.empty?
          groups << [
            I18n.t("forms.scopes_picker.others"),
            without_groups
          ]
        end
        grouped_options_for_select(groups, selected)
      end
    end
  end
end
