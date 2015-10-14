class AddSecondPrimaryAgent < ActiveRecord::Migration
  def change

  	add_reference :units, :primary_agent2, index: true
  end
end
