# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

# Register the additonal path for Webpacker in order to make the module's
# stylesheets available for inclusion.
Decidim::Webpacker.register_path("#{base_path}/app/packs")

# Register the entrypoints for your module. These entrypoints can be included
# within your application using `javascript_pack_tag` and if you include any
# SCSS files within the entrypoints, they become available for inclusion using
# `stylesheet_pack_tag`.
Decidim::Webpacker.register_entrypoints(
  decidim_accountability_simple: "#{base_path}/app/packs/entrypoints/decidim_accountability_simple.js",
  decidim_accountability_simple_admin: "#{base_path}/app/packs/entrypoints/decidim_accountability_simple_admin.js"
)

# Register the main application's stylesheet include statement:
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/accountability_simple/result")
