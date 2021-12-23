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
        # TODO: Update to 0.24+
        Decidim::Accountability::AccountabilityType.define do
          field :statuses, !types[Decidim::Accountability::StatusType] do
            resolve lambda { |component, _args, _ctx|
              Decidim::Accountability::Status.where(component: component)
            }
          end
        end
        Decidim::Accountability::ResultType.define do
          field :locations, !types[Decidim::Locations::LocationType], "The locations for this result"
          field :details, !types[Decidim::AccountabilitySimple::ResultDetailType], "The details for this result", property: :result_details
        end
        Decidim::Accountability::AccountabilityType.define do
          Decidim::AccountabilitySimple::DetailableTypeExtension.define(self)
        end
      end

      initializer "decidim_accountability_simple.mutation_extensions", after: "decidim-api.graphiql" do
        Decidim::Api::MutationType.define do
          MutationExtensions.define(self)
        end
      end

      # TODO: Update to 0.24+ (see plans for example)
      # initializer "decidim_accountability_simple.api_linked_resources", before: :finisher_hook do
      initializer "decidim_accountability_simple.api_linked_resources" do
        # Mark the possible types for accountability result linked resources
        has_linked_types = false
        if Decidim.const_defined?("Proposals")
          has_linked_types = true
          Decidim::Proposals::ProposalType.implements(
            [-> { Decidim::AccountabilitySimple::ResourceLinkInterface }]
          )
        end
        if Decidim.const_defined?("Ideas")
          has_linked_types = true
          Decidim::Ideas::IdeaType.implements(Decidim::AccountabilitySimple::ResourceLinkInterface)
        end
        if Decidim.const_defined?("Plans")
          has_linked_types = true
          Decidim::Plans::PlanType.implements(Decidim::AccountabilitySimple::ResourceLinkInterface)
        end
        if Decidim.const_defined?("Budgets")
          has_linked_types = true
          Decidim::Budgets::ProjectType.implements(
            [-> { Decidim::AccountabilitySimple::ResourceLinkInterface }]
          )
        end
        next unless has_linked_types

        # Add the extra fields to the result and result timeline entry types
        Decidim::Accountability::ResultType.define do
          interfaces [
            # Default (core)
            -> { Decidim::Core::ComponentInterface },
            -> { Decidim::Core::CategorizableInterface },
            -> { Decidim::Comments::CommentableInterface },
            -> { Decidim::Core::ScopableInterface },
            # Extra
            -> { Decidim::AccountabilitySimple::ResourceLinkableInterface }
          ]
        end
        Decidim::Accountability::TimelineEntryType.define do
          field :endDate, Decidim::Core::DateType, "The end date for this timeline entry", property: :end_date
          field :title, Decidim::Core::TranslatedFieldType, "The title for this timeline entry (that overrides the dates)"
        end
      end

      # HACK, because migrations crash if models exists before they are ran
      if ENV["accountability_simple"] != "create_app"
        config.to_prepare do
          # Model extensions
          Decidim::Accountability::Result.send(
            :include,
            Decidim::AccountabilitySimple::ResultExtensions
          )

          # Form extensions
          Decidim::Accountability::Admin::StatusForm.send(
            :include,
            Decidim::AccountabilitySimple::Admin::StatusFormExtensions
          )
          Decidim::Accountability::Admin::ResultForm.send(
            :include,
            Decidim::AccountabilitySimple::Admin::ResultFormExtensions
          )
          Decidim::Accountability::Admin::TimelineEntryForm.send(
            :include,
            Decidim::AccountabilitySimple::Admin::TimelineEntryFormExtensions
          )

          # Command extensions
          Decidim::Accountability::Admin::CreateStatus.send(
            :include,
            Decidim::AccountabilitySimple::Admin::CreateStatusExtensions
          )
          Decidim::Accountability::Admin::UpdateStatus.send(
            :include,
            Decidim::AccountabilitySimple::Admin::UpdateStatusExtensions
          )
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
end
