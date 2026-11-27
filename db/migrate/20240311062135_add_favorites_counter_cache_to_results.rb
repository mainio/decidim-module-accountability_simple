# frozen_string_literal: true

class AddFavoritesCounterCacheToResults < ActiveRecord::Migration[6.1]
  class Result < ApplicationRecord
    self.table_name = "decidim_accountability_results"
  end

  def change
    add_column :decidim_accountability_results, :favorites_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Result.reset_column_information
        Result.find_each do |record|
          # rubocop:disable Rails/SkipsModelValidations
          record.update_columns(
            favorites_count: Decidim::Favorites::Favorite.where(
              decidim_favoritable_type: "Decidim::Accountability::Result",
              decidim_favoritable_id: record.id
            ).count(:all)
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
