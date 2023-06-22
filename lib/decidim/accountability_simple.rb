# frozen_string_literal: true

require_relative "accountability_simple/version"
require_relative "accountability_simple/engine"
require_relative "accountability_simple/api"

module Decidim
  module AccountabilitySimple
    autoload :DetailableTypeExtension, "decidim/accountability_simple/detailable_type_extension"
    autoload :MutationExtensions, "decidim/accountability_simple/mutation_extensions"
  end
end
