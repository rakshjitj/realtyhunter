class MoveListingAgent < ActiveRecord::Migration
  def change
		# should be on landlord (sigh)
  	add_reference :landlords, :listing_agent, index: true
  	add_column :landlords, :listing_agent_percentage, :integer
  	add_column :landlords, :op_fee_percentage, :integer

  	Building.all.each { |b|
  		if !b.landlord.listing_agent
  			if b.listing_agent
  				puts "Copying over #{b.listing_agent.name} to #{b.landlord.code}"
		  		b.landlord.listing_agent = b.listing_agent
		  		b.landlord.save
		  	end
		  	if b.listing_agent_percentage
		  		puts "Copying over #{b.listing_agent_percentage}% to #{b.landlord.code}"
  				b.landlord.listing_agent_percentage = b.listing_agent_percentage
  				b.landlord.save
  			end
  		end
  	}

  end
end
