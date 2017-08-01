class AddMultiTable < ActiveRecord::Migration
  def change
  	change_table :units do |t|
		  t.actable
		end
  end
end
