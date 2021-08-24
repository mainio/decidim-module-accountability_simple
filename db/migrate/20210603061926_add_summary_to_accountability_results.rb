# frozen_string_literal: true

class AddSummaryToAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :summary, :jsonb
  end
end
