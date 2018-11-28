class CreateStreeteasyCounters < ActiveRecord::Migration[5.0]
  def change
    create_table :streeteasy_counters do |t|
      t.integer :residential_listing_id
      t.boolean :streeteasy_flag_check

      t.timestamps
    end
  end
end
