# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AccountabilitySimple

      initializer "decidim_accountability_simple.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
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
            resources :link_collections, except: [:show]
            member do
              put :publish
              put :unpublish
            end
          end
          resource :details, only: [:show, :update]
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
        Decidim::Accountability::MilestoneType.include Decidim::AccountabilitySimple::Api::MilestoneTypeExtensions

        Decidim::Proposals::ProposalType.include Decidim::AccountabilitySimple::Api::ResourceLinkTypeExtensions if Decidim.const_defined?("Proposals")
        Decidim::Budgets::ProjectType.include Decidim::AccountabilitySimple::Api::ResourceLinkTypeExtensions if Decidim.const_defined?("Budgets")
        Decidim::Ideas::IdeaType.include Decidim::AccountabilitySimple::Api::ResourceLinkTypeExtensions if Decidim.const_defined?("Ideas")
        Decidim::Plans::PlanType.include Decidim::AccountabilitySimple::Api::ResourceLinkTypeExtensions if Decidim.const_defined?("Plans")
      end

      initializer "decidim_accountability_simple.mutation_extensions", after: "decidim-api.graphiql" do
        Decidim::Api::MutationType.include Decidim::AccountabilitySimple::MutationExtensions
      end

      initializer "decidim_accountability_simple.overrides", after: "decidim.action_controller" do |app|
        app.config.to_prepare do
          # HACK, because migrations crash if models exists before they are ran
          next if ENV.fetch("accountability_simple", nil) == "create_app"

          # Model extensions
          Decidim::Accountability::Result.include(
            Decidim::AccountabilitySimple::ResultExtensions
          )
          Decidim::Accountability::Milestone.include(
            Decidim::AccountabilitySimple::MilestoneExtensions
          )

          # Form extensions
          Decidim::Accountability::Admin::StatusForm.include(
            Decidim::AccountabilitySimple::Admin::StatusFormExtensions
          )
          Decidim::Accountability::Admin::ResultForm.include(
            Decidim::AccountabilitySimple::Admin::ResultFormExtensions
          )
          Decidim::Accountability::Admin::MilestoneForm.include(
            Decidim::AccountabilitySimple::Admin::MilestoneFormExtensions
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
          Decidim::Accountability::Admin::CreateMilestone.include(
            Decidim::AccountabilitySimple::Admin::CreateMilestoneExtensions
          )
          Decidim::Accountability::Admin::UpdateMilestone.include(
            Decidim::AccountabilitySimple::Admin::UpdateMilestoneExtensions
          )

          # Helper extensions
          Decidim::Accountability::ApplicationHelper.include(
            Decidim::AccountabilitySimple::ApplicationHelperExtensions
          )

          # Controller extensions
          Decidim::Accountability::Admin::StatusesController.include(
            Decidim::AccountabilitySimple::Admin::StatusesControllerExtensions
          )
        end
      end
    end
  end
end
