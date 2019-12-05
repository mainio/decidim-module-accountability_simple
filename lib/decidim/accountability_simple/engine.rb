# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AccountabilitySimple

      initializer "decidim_budgets_enhanced.assets" do |app|
        app.config.assets.precompile += %w(decidim/accountability_simple/result.css)
      end

      initializer "decidim_budgets_enhanced.admin_routes", before: :add_routing_paths do
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

        # Command extensions
        Decidim::Accountability::Admin::CreateResult.send(
          :include,
          Decidim::AccountabilitySimple::Admin::CreateResultExtensions
        )
        Decidim::Accountability::Admin::UpdateResult.send(
          :include,
          Decidim::AccountabilitySimple::Admin::UpdateResultExtensions
        )
      end
    end
  end
end
