# frozen_string_literal: true

class AddEndDateToAccountabilityTimelineEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_accountability_timeline_entries, :end_date, :date
    add_index :decidim_accountability_timeline_entries, :end_date
  end
end
