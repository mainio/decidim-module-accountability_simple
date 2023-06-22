# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module DetailableTypeExtension
      def self.define(type)
        type.field :availableDetails, !type.types[Decidim::AccountabilitySimple::ResultDetailType] do
          description "The available details for the record"

          resolve lambda { |obj, _args, _ctx|
            Decidim::AccountabilitySimple::ResultDetail.where(
              accountability_result_detailable: obj
            )
          }
        end
      end
    end
  end
end
