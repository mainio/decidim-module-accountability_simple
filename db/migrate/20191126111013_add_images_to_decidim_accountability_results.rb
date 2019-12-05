# frozen_string_literal: true

class AddImagesToDecidimAccountabilityResults < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_results, :main_image, :string
    add_column :decidim_accountability_results, :list_image, :string
  end
end
