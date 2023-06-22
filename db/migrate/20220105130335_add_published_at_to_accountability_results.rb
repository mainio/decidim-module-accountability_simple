# frozen_string_literal: true

class AddPublishedAtToAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :published_at, :datetime, index: true

    reversible do |direction|
      direction.up do
        execute "UPDATE decidim_accountability_results SET published_at = updated_at"
      end
    end
  end
end
