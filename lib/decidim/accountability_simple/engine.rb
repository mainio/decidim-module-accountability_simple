# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AccountabilitySimple

      initializer "decidim_accountability_simple.assets" do |app|
        app.config.assets.precompile += %w(
          decidim/accountability_simple/result.css
          decidim/accountability_simple/icons.svg
        )
      end

      initializer "decidim_accountability_simple.admin_assets" do |app|
        app.config.assets.precompile += %w(
          decidim_accountability_simple_admin_manifest.js
          decidim/accountability_simple/admin/results.js
        )
      end

      initializer "decidim_accountability_simple.mount_routes", before: :add_routing_paths do
        Decidim::Core::Engine.routes do
          mount Decidim::AccountabilitySimple::Engine => "/"
        end
      end

      initializer "decidim_accountability_simple.admin_routes", before: :add_routing_paths do
        Decidim::Accountability::AdminEngine.routes.append do
          resources :results, only: [] do
            resources :attachment_collections
            resources :attachments
            member do
              put :publish
              put :unpublish
            end
          end
          resource :details, only: [:index, :show, :update]
        end
      end

      initializer "decidim_accountability_simple.component_settings" do
        Decidim.find_component_manifest(:accountability).tap do |component|
          component.settings(:global) do |settings|
            settings.attribute :geocoding_enabled, type: :boolean
          end
        end
      end

      initializer "decidim_accountability_simple.add_cells_view_paths", before: "decidim_accountability.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::AccountabilitySimple::Engine.root}/app/cells")
      end

      initializer "decidim_accountability_simple.api_extensions" do
        Decidim::Accountability::AccountabilityType.include Decidim::AccountabilitySimple::Api::AccountabilityTypeExtensions
        Decidim::Accountability::ResultType.include Decidim::AccountabilitySimple::Api::ResultTypeExtensions
        Decidim::Accountability::TimelineEntryType.include Decidim::AccountabilitySimple::Api::TimelineEntryTypeExtensions

        Decidim::Proposals::ProposalType.include Decidim::AccountabilitySimple::Api::ResourceLinkTypeExtensions if Decidim.const_defined?("Proposals")
        Decidim::Budgets::ProjectType.include Decidim::AccountabilitySimple::Api::ResourceLinkTypeExtensions if Decidim.const_defined?("Budgets")
        Decidim::Ideas::IdeaType.include Decidim::AccountabilitySimple::Api::ResourceLinkTypeExtensions if Decidim.const_defined?("Ideas")
        Decidim::Plans::PlanType.include Decidim::AccountabilitySimple::Api::ResourceLinkTypeExtensions if Decidim.const_defined?("Plans")
      end

      initializer "decidim_accountability_simple.mutation_extensions", after: "decidim-api.graphiql" do
        Decidim::Api::MutationType.include Decidim::AccountabilitySimple::MutationExtensions
      end

      # HACK, because migrations crash if models exists before they are ran
      config.to_prepare do
        next if ENV["accountability_simple"] == "create_app"

        # Model extensions
        Decidim::Accountability::Result.include(
          Decidim::AccountabilitySimple::ResultExtensions
        )
        Decidim::Accountability::TimelineEntry.include(
          Decidim::AccountabilitySimple::TimelineEntryExtensions
        )

        # Form extensions
        Decidim::Accountability::Admin::StatusForm.include(
          Decidim::AccountabilitySimple::Admin::StatusFormExtensions
        )
        Decidim::Accountability::Admin::ResultForm.include(
          Decidim::AccountabilitySimple::Admin::ResultFormExtensions
        )
        Decidim::Accountability::Admin::TimelineEntryForm.include(
          Decidim::AccountabilitySimple::Admin::TimelineEntryFormExtensions
        )

        # Command extensions
        Decidim::Accountability::Admin::CreateStatus.include(
          Decidim::AccountabilitySimple::Admin::CreateStatusExtensions
        )
        Decidim::Accountability::Admin::UpdateStatus.include(
          Decidim::AccountabilitySimple::Admin::UpdateStatusExtensions
        )
        Decidim::Accountability::Admin::CreateResult.include(
          Decidim::AccountabilitySimple::Admin::CreateResultExtensions
        )
        Decidim::Accountability::Admin::UpdateResult.include(
          Decidim::AccountabilitySimple::Admin::UpdateResultExtensions
        )
        Decidim::Accountability::Admin::CreateTimelineEntry.include(
          Decidim::AccountabilitySimple::Admin::CreateTimelineEntryExtensions
        )
        Decidim::Accountability::Admin::UpdateTimelineEntry.include(
          Decidim::AccountabilitySimple::Admin::UpdateTimelineEntryExtensions
        )

        # Helper extensions
        Decidim::Accountability::ApplicationHelper.include(
          Decidim::AccountabilitySimple::ApplicationHelperExtensions
        )
        Decidim::ScopesHelper.include(
          Decidim::AccountabilitySimple::ScopesHelperExtensions
        )
      end
    end
  end
end
