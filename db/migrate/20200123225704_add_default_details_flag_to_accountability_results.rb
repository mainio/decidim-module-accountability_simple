# frozen_string_literal: true

class AddDefaultDetailsFlagToAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :use_default_details, :boolean, default: true, null: false
  end
end
