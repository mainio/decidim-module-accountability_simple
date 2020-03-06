# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module ResultsHelper
      def component_filter_values_with_space(components)
        components.map do |c|
          [
            translated_attribute(c.participatory_space.title, c.participatory_space.organization),
            c.id
          ]
        end
      end

      def component_filter_groupped_values_with_space(components)
        groups = {}
        others_group = []

        components.map do |c|
          space = c.participatory_space

          value = [
            translated_attribute(space.title, space.organization),
            c.id
          ]

          if space.is_a?(ParticipatoryProcess) && space.participatory_process_group
            group = space.participatory_process_group
            key = "participatory_process_group_#{group.id}".to_sym

            groups[key] ||= {
              title: translated_attribute(group.name, space.organization),
              values: []
            }
            groups[key][:values] << value
          else
            others_group << value
          end
        end

        return others_group if groups.empty?

        options = groups.map { |_key, grp| [grp[:title], grp[:values]] }
        unless others_group.empty?
          options << [
            t("decidim.accountability_simple.results.components_filter.others"),
            others_group
          ]
        end

        options
      end
    end
  end
end
