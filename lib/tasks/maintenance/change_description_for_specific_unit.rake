namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :change_description_for_specific_unit => :environment do
		log = ActiveSupport::Logger.new('log/change_description_for_specific_unit.log')
		start_time = Time.now

		puts "change_description_for_specific_unit..."
		log.info "change_description_for_specific_unit..."

		@listings = Unit.where(building_id: 4708)
		
		@listings.each {|listing|
				listing.residential_listing.update!(description: "<p><b>THE APARTMENTS </b><br />
The interior aesthetics of the apartments vary, creating diverse spaces that have a sense of local and global style. Open spaces, beautiful sunny views and a sense of both calm and buzzing community are available and threaded throughout the apartments and floors. There is a trifecta of finishes that make each space feel bold and original. Some have clean bright wooden details and artistic flair, some are contemporary and clean with sleek industrial and metallic surfaces and some have more classic dark wood finishes. All are beautiful, cool and modern. Outdoor spaces are available on many. The views of the city, brooklyn and queens, depending on location, are expansive and bright. </p>

<p>The units amenities include:</p>
<ul><li>Stainless steel appliances</li>
<li>Dishwasher</li>
<li>Microwaves</li>
<li>Washer and Dryer (In unit)</li>
<li>Hardwood Floors</li>
<li>Central Heat/AC</li>
<li>Bluetooth Capabilities</li>
<li>Outdoor Space/Terraces/Balconies</li></ul>

<p><b>THE BUILDING</b><br />
From the moment of entry, Denizen Bswckprovides a new kind of space, it’s lobby creates a sense of community, rich with local art, innovative architecture and layered vistas of the parks, retail and recreational spaces available. Spanning two city blocks, this pair of eight story buildings is a 900 hundred unit rental community that extends far beyond the definition of an apartment complex. It is bisected by a pastoral public park and has an innumerable amount of upscale amenities and perks. </p>
<p>The Building Amenities include:</p>
<ul><li>Rooftop Pet Run</li>
<li>Mini Golf</li>
<li>Beer Brewery</li>
<li>Wine Brewery</li>
<li>Tenant Lounge</li>
<li>Dog Spa</li>
<li>Kids Room featuring rock climbing</li>
<li>Community Chef’s Kitchen</li>
<li>Conference Rooms</li>
<li>Parking</li>
<li>Bike Storage</li></li>
<li>Experience Coordinator</li>
<li>Doorman, Concierge and Package Area</li>
<li>Cold Storage</li>
<li>Co-working space</li>
<li>Private Art Studios</li>
<li>Green Market Area</li></ul>

<p><b>THE COMMUNITY</b><br />
From honey bees to aerialists to michelin stars, Bushwick has evolved into a iconic place to live, work and play. It maintains it’s raw unpolished vibe while also being home to award winning restaurants, world renowned art and thriving community. The nearby hotspots include, but are definitely not limited to, Robertas, Pinebox, 983 Living Room, Archie’s Pizza, House of Yes, The Bakeshop and MOMO sushi.This spot is a three block walk to the JMZ trains a seven minute walk to the L train. </p>

<p>Check out the website: <a href='https://denizen.myspacenyc.com' target='_blank'>https://denizen.myspacenyc.com</a></p>")
		}

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end