# This feed is based largely off the Streeteasy feed spec, but augmented with specific fields
# that only Nestio uses. Please reference their feed documentation:
# https://drive.google.com/open?id=0B_EU2U2294snZE9ZQXFxclFxMzA

# url looks like <base_url>/syndication/1/streeteasy
xml.instruct! :xml, :version => "1.0"
xml.streeteasy :version => "1.6" do
  xml.properties do

    @listings.each do |listing|

      # NOTE: this is super hacky. We should filter this out before sending
      # to the view.
      if !@primary_agents[listing.unit_id].blank? &&
            @primary_agents[listing.unit_id][0].name == @company.name
        # skip our generic catch-all account
        next
      end

      xml.property do# type: @ptype, status: @status, id: listing.listing_id, url: listing.public_url do
        if listing.status == "active"
          xml.status "active"
        elsif listing.status == "pending"
          xml.status "in contract"
        else
          # we leave this here for completion. as of right now, this is never used.
          xml.status "rented"
        end

        xml.tag! 'rental-terms' do
          xml.tag! 'rental-broker-fee', listing.has_fee ? 'Yes' : 'No'
          if !listing.lease_start.nil?
            xml.tag! 'lease-min-length-months', listing.lease_start
          end
          if !listing.lease_end.nil?
            xml.tag! 'lease-min-length-months', listing.lease_end
          end
        end

        xml.location do
          xml.tag! 'unit-number', listing.building_unit
          xml.tag! 'street-address', listing.street_number + " " + listing.route
          xml.tag! 'city-name', listing.sublocality
          xml.tag! 'state-code', listing.administrative_area_level_1_short
          xml.zipcode listing.postal_code
        end

        xml.details do
          if !listing.has_fee
            xml.tag! 'commission-type', 'owner pays'
          end

          if listing.available_by
            xml.tag! 'date-available', listing.available_by.strftime("%Y-%m-%d") # rentals only
          end

          if listing.r_id && !listing.description.empty?
            xml.description h raw sanitize listing.description,
                tags: %w(h1 h2 h3 h4 h5 h6 p i b strong em a ol ul li q blockquote font span br div)
          elsif listing.s_id && !listing.public_description.empty?
            xml.description h raw sanitize listing.public_description,
                tags: %w(h1 h2 h3 h4 h5 h6 p i b strong em a ol ul li q blockquote font span br div)
          end

          # TODO
          if listing.exclusive
            xml.tag! 'exclusive-type', 'exclusive'
          end

          if !listing.floor.nil?
            xml.tag! 'floor-of-unit', listing.floor
          end

          if !listing.r_beds.nil?
            xml.tag! 'num-bedrooms', listing.r_beds.to_i
          elsif !listing.s_beds.nil?
            xml.tag! 'num-bedrooms', listing.s_beds.to_i
          end

          baths = nil
          if listing.r_baths
            baths = listing.r_baths
          elsif listing.s_baths
            baths = listing.s_baths
          end

          xml.tag! 'num-bathrooms', baths

          if listing.r_tenant_occupied
            xml.tag! 'occupancy-status', 'occupied'
          elsif listing.s_tenant_occupied
            xml.tag! 'occupancy-status', 'occupied'
          else
            xml.tag! 'occupancy-status', 'vacant'
          end

          # TODO: our output needs to be sanitized here
          if @pet_policies[listing.building_id] && @pet_policies[listing.building_id][0].pet_policy_name
            policy = @pet_policies[listing.building_id][0].pet_policy_name


            if policy == 'pets allowed'
              xml.tag! 'pets-policy', 'pets ok'
            elsif policy == 'no pets'
              xml.tag! 'no pets'
            elsif policy == 'small pets ok (<30 lbs)' || policy == 'cats/small dogs'
              xml.tag! 'small pets'
            elsif policy == 'cats only'
              xml.tag! 'pets-policy', policy
            elsif policy == 'dogs only'
              xml.tag! 'pets-policy', policy
            else
              xml.tag! 'pets-policy', 'case by case'
            end

          end

          xml.tag! 'property-type', "apartment"

          xml.tag! 'provider-listingid', listing.listing_id

          xml.price listing.rent

          if listing.r_total_room_count
            xml.tag! 'room-count', listing.r_total_room_count.to_i
          end
        end #details

        if @bldg_images[listing.building_id]
          xml.pictures do
            @bldg_images[listing.building_id].each do |i|
              xml.picture do
                xml.tag! 'picture-url', i.file.url(:large)
              end
            end
          end
        end
        if @images[listing.unit_id]
          xml.pictures do
            @images[listing.unit_id].each do |i|
              xml.picture do
                xml.tag! 'picture-url', i.file.url(:large)
              end
            end
          end
        end

        if !@primary_agents[listing.unit_id].blank?
          xml.agents do
            @primary_agents[listing.unit_id].each do |agent|
              xml.agent do
                xml.tag! 'agent-name', agent.name
                xml.tag! 'agent-email', agent.email
                xml.tag! 'agent-phone', agent.mobile_phone_number
              end
            end
          end
        end # agents

        if !@open_houses[listing.unit_id].blank?
          xml.tag! 'open-homes' do
            @open_houses[listing.unit_id].each do |oh|
              xml.tag! 'open-home' do
                xml.tag! 'start-time', oh.start_time.strftime("%H:%M")
                xml.tag! 'end-time', oh.end_time.strftime("%H:%M")
                xml.date oh.day.strftime("%Y-%m-%d")
                xml.details do
                  xml.tag! 'open-house-appointment-only', true
                end
              end
            end
          end
        end

        # streeteasy has their own approved list of amenities
        # doorman, gym, pool, elevator, garage, parking, balcony, storage, patio, fireplace
        # washerDryer, dishwasher, furnished, pets, other

        @other_amenities = []
        attribute_found = {}

        xml.tag! 'detailed-characteristics' do
          if @residential_amenities && @residential_amenities[listing.unit_id] &&
              @residential_amenities[listing.unit_id].length > 0
            xml.tag! 'other-amenities' do
              @residential_amenities[listing.unit_id].map{|a| a.name}.each do |amenity|
                blacklisted_amenities = ['diswasher', 'furnished', 'washer/dryer hookups']
                if !amenity.include? amenity
                  xml.tag! 'other-amenity', amenity
                end
              end
            end
          end

          if @building_amenities[listing.building_id]
            @building_amenities[listing.building_id].map{|b| b.name}.each do |bm|
              case bm
                when "laundry in building"
                  if !attribute_found["washerDryer"]
                    attribute_found["washerDryer"] = 1
                    xml.tag! 'building-has-laundry', xml.washerDryer ? 'Yes' : 'No'
                  end
                  @laundry_included = true
                when "balcony"
                  xml.tag! 'has-balcony', xml.balcony
                when "doorman"
                  xml.tag! 'building-has-doorman', xml.doorman ? 'Yes' : 'No'
                when "elevator"
                  xml.tag! 'building-has-elevator', xml.elevator ? 'Yes' : 'No'
                when "gym", "fitness center", "sauna"
                  if !attribute_found["gym"]
                    attribute_found["gym"] = 1
                    xml.tag! 'building-has-fitness-center', 'Yes'
                  end
                else
                  @other_amenities << bm
                end
              end # case
            end
            if @other_amenities.length > 0
              xml.tag! 'building-other-amenities' do
                @other_amenities.each do |amenity|
                  xml.tag! 'building-other-amenity', amenity
                end
              end # building-other-amenities
            end # other_amenities
          end

      end # property
    end # listings.each
  end # properties
end #streeteasy
#end # cache
