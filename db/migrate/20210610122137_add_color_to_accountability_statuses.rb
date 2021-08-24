# frozen_string_literal: true

class AddColorToAccountabilityStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_statuses, :color, :string
  end
end
