json.prettify! if %w(1 yes true).include?(params["pretty"])

json.total_items @listings.total_count
json.total_pages @listings.total_pages
json.page @listings.current_page

#if @listing_type == 10

#	json.items do
#		json.partial! 'api/v1/units/runit', collection: @listings, as: :listing, locals: {images: @images, listing_type: @listing_type, primary_agents: @primary_agents}
#	end

#elsif @listing_type == 20
#elsif @listing_type == 30

#	json.items do
#		json.partial! 'api/v1/units/cunit', collection: @listings, as: :listing, locals: {images: @images, listing_type: @listing_type, primary_agents: @primary_agents}
#	end

#else

	
		json.items do
			json.partial! 'api/v1/units/all_unit', collection: @listings, as: :listing, locals: {images: @images, listing_type: @listing_type, primary_agents: @primary_agents}
		end
	

#end
