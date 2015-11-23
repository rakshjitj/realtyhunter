class AddStateToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :state, :integer, default: 0, null: false
  end
end
