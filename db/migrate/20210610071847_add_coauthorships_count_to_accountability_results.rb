# frozen_string_literal: true

class AddCoauthorshipsCountToAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :coauthorships_count, :integer, null: false, default: 0
    add_index :decidim_accountability_results, :coauthorships_count, name: "idx_decidim_accountability_results_on_result_coauth_count"
  end
end
