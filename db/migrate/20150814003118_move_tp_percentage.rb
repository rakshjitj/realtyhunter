class MoveTpPercentage < ActiveRecord::Migration
  def change
  	add_column :landlords, :has_fee, :boolean  
    add_column :landlords, :tp_fee_percentage, :integer

    Building.all.each { |b|
			if b.has_fee
  			b.landlord.has_fee = b.has_fee
  			b.landlord.save
  		end
  		if b.tp_fee_percentage
  			b.landlord.tp_fee_percentage = b.tp_fee_percentage
  			b.landlord.save
  		end

  		if b.op_fee_percentage
  			b.landlord.op_fee_percentage = b.op_fee_percentage
  			b.landlord.save
  		end
  	}

  	remove_reference :buildings, :listing_agent, index: true
  	remove_column :buildings, :listing_agent_percentage, :integer
    remove_column :residential_amenities_units, :residential_unit_id, :string
    #remove_column :buildings, :has_fee, :boolean
    #remove_column :buildings, :op_fee_percentage, :integer
    #remove_column :buildings, :tp_fee_percentage, :integer
  end
end
