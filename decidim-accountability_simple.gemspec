# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/accountability_simple/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-accountability_simple"
  spec.version = Decidim::AccountabilitySimple.version
  spec.required_ruby_version = ">= 3.1"
  spec.authors = ["Antti Hukkanen"]
  spec.email = ["antti.hukkanen@mainiotech.fi"]

  spec.summary = "Simplified accountability module for Decidim."
  spec.description = "Simplifies the Decidim's own accountability module UI."
  spec.homepage = "https://github.com/mainio/decidim-module-accountability_simple"
  spec.license = "AGPL-3.0"

  spec.files = Dir[
    "{app,config,db,lib}/**/*",
    "LICENSE-AGPLv3.txt",
    "Rakefile",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-accountability", Decidim::AccountabilitySimple.decidim_version
  spec.add_dependency "decidim-admin", Decidim::AccountabilitySimple.decidim_version
  spec.add_dependency "decidim-apifiles", Decidim::AccountabilitySimple.decidim_version
  spec.add_dependency "decidim-core", Decidim::AccountabilitySimple.decidim_version
  spec.add_dependency "decidim-favorites", Decidim::AccountabilitySimple.decidim_version
  spec.add_dependency "decidim-locations", Decidim::AccountabilitySimple.decidim_version
  spec.add_dependency "decidim-nav", Decidim::AccountabilitySimple.decidim_version
  spec.add_dependency "decidim-participatory_processes", Decidim::AccountabilitySimple.decidim_version
  spec.add_dependency "decidim-tags", Decidim::AccountabilitySimple.decidim_version

  spec.add_development_dependency "decidim-dev", Decidim::AccountabilitySimple.decidim_version

  # These extra development dependencies are needed for factory loading for the
  # tests
  spec.add_development_dependency "decidim-assemblies", Decidim::AccountabilitySimple.decidim_version
  spec.add_development_dependency "decidim-comments", Decidim::AccountabilitySimple.decidim_version
end
