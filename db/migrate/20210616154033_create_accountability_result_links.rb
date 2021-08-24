# frozen_string_literal: true

class CreateAccountabilityResultLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_accountability_simple_result_links do |t|
      t.references :decidim_accountability_result, index: { name: :index_decidim_accountability_result_links_on_results_id }
      t.integer :position
      t.jsonb :label
      t.jsonb :url
    end
  end
end
