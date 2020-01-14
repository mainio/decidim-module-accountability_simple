# frozen_string_literal: true

class AddThemeColorToDecidimAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :theme_color, :string
  end
end
