# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    autoload :ResourceLinkInterface, "decidim/api/resource_link_interface"
    autoload :ResourceLinkableInterface, "decidim/api/resource_linkable_interface"
    autoload :ResultDefaultDetailAttributes, "decidim/api/result_default_detail_attributes"
    autoload :ResultDetailAttributes, "decidim/api/result_detail_attributes"
    autoload :ResultDetailType, "decidim/api/result_detail_type"
    autoload :ResultDetailValueType, "decidim/api/result_detail_value_type"
    autoload :ResultLinkAttributes, "decidim/api/result_link_attributes"
    autoload :ResultLinkType, "decidim/api/result_link_type"
    autoload :ResultMutationType, "decidim/api/result_mutation_type"
    autoload :ResultTimelineEntryMutationType, "decidim/api/result_timeline_entry_mutation_type"

    module Api
      autoload :Permissions, "decidim/accountability_simple/api/permissions"

      autoload :AccountabilityTypeExtensions, "decidim/accountability_simple/api/types/accountability_type_extensions"
      autoload :ResourceLinkTypeExtensions, "decidim/accountability_simple/api/types/resource_link_type_extensions"
      autoload :ResultTypeExtensions, "decidim/accountability_simple/api/types/result_type_extensions"
      autoload :TimelineEntryTypeExtensions, "decidim/accountability_simple/api/types/timeline_entry_type_extensions"
    end
  end
end
