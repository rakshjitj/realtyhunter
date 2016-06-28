class SyndicationCtrlFlags < ActiveRecord::Migration
  def change
    add_column :units, :syndication_status, :integer, default: 0
    add_column :units, :has_stock_photos, :boolean, default: false
  end
end
