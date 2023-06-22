# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This interface is used to resolve the resource link types for the
    # accountability results.
    ResourceLinkableInterface = GraphQL::InterfaceType.define do
      name "ResultResourceLinkableInterface"
      description "An interface that can be used in objects with resource links"

      # These are the resources that are linked from the plan to the related
      # object.
      field :linkedResources, types[Decidim::AccountabilitySimple::ResourceLinkInterface] do
        description "The linked resources for this result"

        resolve ->(obj, _args, _ctx) {
          resources = obj.resource_links_from.map(&:to).reject do |resource|
            resource.nil? ||
              (resource.respond_to?(:published?) && !resource.published?) ||
              (resource.respond_to?(:hidden?) && resource.hidden?) ||
              (resource.respond_to?(:withdrawn?) && resource.withdrawn?)
          end
          return nil unless resources.any?

          resources
        }
      end
    end
  end
end
