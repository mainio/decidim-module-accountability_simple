# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # This interface represents a result detailable object.
    ResultDetailableInterface = GraphQL::InterfaceType.define do
      name "ResultDetailableInterface"
      description "A result detailable interface"

      field :id, !types.ID, "The result detailable's ID"

      field :type do
        type !types.String
        description "The result detailable's class name. e.g. `Decidim::Component`"

        resolve lambda { |obj, _args, _ctx|
          obj.class.name
        }
      end

      field :availableDetails do
        type !types[Decidim::AccountabilitySimple::ResultDetailType]
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
