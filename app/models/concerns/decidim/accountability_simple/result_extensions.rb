# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module ResultExtensions
      extend ActiveSupport::Concern

      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::HasUploadValidations
      include Decidim::Tags::Taggable
      include Decidim::Locations::Locatable
      include Decidim::Coauthorable
      include Decidim::Publicable
      include Decidim::Favorites::Favoritable

      included do
        remove_coauthorships_requirement!

        has_one_attached :main_image
        validates_upload :main_image, uploader: Decidim::AccountabilitySimple::MainImageUploader
        has_one_attached :list_image
        validates_upload :list_image, uploader: Decidim::AccountabilitySimple::ListImageUploader

        has_many :result_details, -> { order(:position) }, as: :accountability_result_detailable,
                                                           class_name: "Decidim::AccountabilitySimple::ResultDetail"
        has_many :result_detail_values, class_name: "Decidim::AccountabilitySimple::ResultDetailValue",
                                        foreign_key: "decidim_accountability_result_id",
                                        dependent: :destroy
        has_many :result_link_collections,
                 -> { order(:position) },
                 class_name: "Decidim::AccountabilitySimple::ResultLinkCollection",
                 foreign_key: "decidim_accountability_result_id",
                 inverse_of: :result,
                 dependent: :destroy
        has_many :result_links, -> { order(:position) }, class_name: "Decidim::AccountabilitySimple::ResultLink",
                                                         foreign_key: "decidim_accountability_result_id",
                                                         dependent: :destroy

        def result_default_details
          Decidim::AccountabilitySimple::ResultDetail.where(
            accountability_result_detailable: component
          ).order(:position)
        end

        # Gets the default details and result specific details
        def result_all_details
          return result_details unless use_default_details?

          Decidim::AccountabilitySimple::ResultDetail.where(
            "(accountability_result_detailable_type = ? AND accountability_result_detailable_id = ?)"\
            " OR "\
            "(accountability_result_detailable_type = ? AND accountability_result_detailable_id = ?)",
            Decidim::Accountability::Result.name,
            id,
            Decidim::Component.name,
            component.id
          ).order(
            accountability_result_detailable_type: :desc,
            position: :asc
          )
        end

        # Create i18n ransackers for :title and :description.
        # Create the :search_text ransacker alias for searching from both of these.
        ransacker_i18n_multi :search_text, [:title, :description]
      end

      class_methods do
        def remove_coauthorships_requirement!
          validators_on(:coauthorships).each do |v|
            v.attributes.delete(:coauthorships) if v.is_a?(ActiveRecord::Validations::PresenceValidator)
          end
        end

        def geocoded_data
          joins(
            <<~SQLJOIN.squish
              LEFT JOIN decidim_locations_locations
                ON decidim_locations_locations.decidim_locations_locatable_id = decidim_accountability_results.id
                AND decidim_locations_locations.decidim_locations_locatable_type = '#{Arel.sql(name)}'
            SQLJOIN
          ).where.not(
            decidim_locations_locations: { decidim_locations_locatable_id: nil }
          ).where.not(
            decidim_locations_locations: { latitude: nil }
          ).where.not(
            decidim_locations_locations: { longitude: nil }
          ).where(
            # Define the latitude/longitude bounds to only return valid lat/long
            # data to the map within the world bounds.
            <<~SQLLOC.squish
              decidim_locations_locations.latitude >= -85
              AND decidim_locations_locations.latitude <= 85
              AND decidim_locations_locations.longitude >= -180
              AND decidim_locations_locations.longitude <= 180
              AND (decidim_locations_locations.latitude != 0 OR decidim_locations_locations.longitude != 0)
            SQLLOC
          ).pluck(
            :id,
            Arel.sql("CASE #{locale_case("decidim_accountability_results.title")} END AS geotitle"),
            Arel.sql("CASE #{locale_case("decidim_accountability_results.summary")} END AS geosummary"),
            Arel.sql("CASE #{locale_case("decidim_accountability_results.description")} END AS geodescription"),
            Arel.sql(
              <<~SQLCASE.squish
                CASE
                  WHEN CHAR_LENGTH(decidim_locations_locations.address::text) > 0 THEN decidim_locations_locations.address
                  #{locale_case("decidim_accountability_results.title")}
                END AS geoaddress
              SQLCASE
            ),
            "decidim_locations_locations.latitude",
            "decidim_locations_locations.longitude"
          )
        end

        private

        def locale_case(column)
          locale = Arel::Nodes.build_quoted(I18n.locale.to_s).to_sql
          default_locale = Arel::Nodes.build_quoted(I18n.default_locale.to_s).to_sql

          return "WHEN true THEN #{column}->>#{locale}" if locale == default_locale

          <<~SQLCASE.squish
            WHEN CHAR_LENGTH((#{column}->>#{locale})::text) > 0 THEN #{column}->>#{locale}
            ELSE #{column}->>#{default_locale}
          SQLCASE
        end
      end
    end
  end
end
