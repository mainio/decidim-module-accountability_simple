# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This interface is used to resolve the resource link types for the
    # accountability results.
    module ResourceLinkableInterface
      include Decidim::Api::Types::BaseInterface

      graphql_name "ResultResourceLinkableInterface"
      description "An interface that can be used in objects with resource links"

      field(
        :linked_resources,
        [Decidim::AccountabilitySimple::ResourceLinkInterface, { null: true }],
        "The linked resources for this result",
        null: true
      )

      # rubocop:disable Metrics/CyclomaticComplexity
      def linked_resources
        resources = object.resource_links_from.map(&:to).reject do |resource|
          resource.nil? ||
            (resource.respond_to?(:published?) && !resource.published?) ||
            (resource.respond_to?(:hidden?) && resource.hidden?) ||
            (resource.respond_to?(:withdrawn?) && resource.withdrawn?)
        end
        return nil unless resources.any?

        resources
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
