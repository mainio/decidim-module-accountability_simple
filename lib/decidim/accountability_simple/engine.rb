# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AccountabilitySimple

      initializer "decidim_accountability_simple.assets" do |app|
        app.config.assets.precompile += %w(decidim/accountability_simple/result.css)
      end

      initializer "decidim_accountability_simple.admin_assets" do |app|
        app.config.assets.precompile += %w(decidim_accountability_simple_admin_manifest.js
                                           decidim/accountability_simple/admin/results.js)
      end

      initializer "decidim_accountability_simple.admin_routes", before: :add_routing_paths do
        Decidim::Accountability::AdminEngine.routes.append do
          resources :results, only: [] do
            resources :attachment_collections
            resources :attachments
          end
        end
      end

      config.to_prepare do
        # Model extensions
        Decidim::Accountability::Result.send(
          :include,
          Decidim::AccountabilitySimple::ResultExtensions
        )

        # Form extensions
        Decidim::Accountability::Admin::ResultForm.send(
          :include,
          Decidim::AccountabilitySimple::Admin::ResultFormExtensions
        )
        Decidim::Accountability::Admin::TimelineEntryForm.send(
          :include,
          Decidim::AccountabilitySimple::Admin::TimelineEntryFormExtensions
        )

        # Command extensions
        Decidim::Accountability::Admin::CreateResult.send(
          :include,
          Decidim::AccountabilitySimple::Admin::CreateResultExtensions
        )
        Decidim::Accountability::Admin::UpdateResult.send(
          :include,
          Decidim::AccountabilitySimple::Admin::UpdateResultExtensions
        )
        Decidim::Accountability::Admin::CreateTimelineEntry.send(
          :include,
          Decidim::AccountabilitySimple::Admin::CreateTimelineEntryExtensions
        )
        Decidim::Accountability::Admin::UpdateTimelineEntry.send(
          :include,
          Decidim::AccountabilitySimple::Admin::UpdateTimelineEntryExtensions
        )

        # Helper extensions
        Decidim::Accountability::ApplicationHelper.send(
          :include,
          Decidim::AccountabilitySimple::ApplicationHelperExtensions
        )
      end
    end
  end
end
