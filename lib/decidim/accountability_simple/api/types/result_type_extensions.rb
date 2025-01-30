# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Api
      module ResultTypeExtensions
        def self.included(type)
          type.implements Decidim::Core::AttachableInterface
          type.implements Decidim::Apifiles::AttachableCollectionsInterface
          type.implements Decidim::AccountabilitySimple::ResourceLinkableInterface
          type.implements Decidim::Locations::LocationsInterface
          type.implements Decidim::Tags::TagsInterface

          type.field :published_at, Decidim::Core::DateTimeType, "The date and time this result was published at", null: true
          type.field :summary, Decidim::Core::TranslatedFieldType, "The summary for this result", null: false
          type.field :main_image, GraphQL::Types::String, "The main image URL for this result", null: true
          type.field :main_image_blob, Decidim::Apifiles::BlobType, "The main image file blob for this result", null: true
          type.field :list_image, GraphQL::Types::String, "The list image (thumbnail) URL for this result", null: true
          type.field :list_image_blob, Decidim::Apifiles::BlobType, "The list image (thumbnail) file blob for this result", null: true
          type.field :default_details, [Decidim::AccountabilitySimple::ResultDetailType], "The default details for this result", null: false
          type.field :details, [Decidim::AccountabilitySimple::ResultDetailType], "The details for this result", null: false
          type.field(
            :link_collections,
            [Decidim::AccountabilitySimple::ResultLinkCollectionType],
            "The links collections for this resource",
            method: :result_link_collections,
            null: false
          )
          type.field(
            :links,
            [Decidim::AccountabilitySimple::ResultLinkType],
            "The links for this resource",
            method: :result_links,
            null: false
          )
        end

        def main_image
          return unless object.main_image.attached?

          object.attached_uploader(:main_image).url
        end

        def main_image_blob
          object.main_image.blob
        end

        def list_image
          return unless object.list_image.attached?

          object.attached_uploader(:list_image).url
        end

        def list_image_blob
          object.list_image.blob
        end

        def default_details
          context.scoped_context.merge!(parent: object)

          object.result_default_details
        end

        def details
          context.scoped_context.merge!(parent: object)

          object.result_details
        end
      end
    end
  end
end
