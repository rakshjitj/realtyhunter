class UnitMailer < ApplicationMailer

  def inaccuracy_reported(listing_id, reporter_id, message, price_drop_request)
    @message = message
    @listing = ResidentialListing.where(id: listing_id).first
    if !@listing
      @listing = SalesListing.where(id: listing_id).first
    end

    @reporter = User.where(id: reporter_id).first
    @price_drop_request = price_drop_request

    mail to: ['info@myspacenyc.com', 'valentina@myspacenyc.com', 'smullahy@myspacenyc.com', 'belle@myspacenyc.com', 'mcohen@myspacenyc.com', 'ckwoka@myspacenyc.com', 'tprice@myspacenyc.com'],
      cc: @reporter.email,
    	subject: "Feedback provided for #{@listing.street_address_and_unit}",
    	reply_to: @reporter.email,
      tag: 'residential_inaccuracy',
      track_opens:'true'
  end

  def feedback_report_notifaction(reporter_id)
    @reporter = User.where(id: reporter_id).first
    mail to: @reporter.email,
      subject: "Feedback Report Submitted",
      reply_to: @reporter.email,
      tag: 'residential_inaccuracy',
      track_opens:'true'
  end

  def commercial_inaccuracy_reported(listing_id, reporter_id, message, price_drop_request)
    @message = message
    @listing = CommercialListing.where(id: listing_id).first
    @reporter = User.where(id: reporter_id).first
    @price_drop_request = price_drop_request

    mail to: 'info@myspacenyc.com',
      cc: @reporter.email,
    	subject: "Feedback provided for commercial Unit: #{@listing.street_address_and_unit}",
    	reply_to: @reporter.email,
      tag: 'commercial_inaccuracy',
      track_opens:'true'
  end

  def send_residential_listings(source_agent_id, listing_ids, recipients, sub, msg)
    @source_agent = User.where(id: source_agent_id).first
    @listings = ResidentialListing.listings_by_id(@source_agent, listing_ids)
    @images = ResidentialListing.get_images(@listings)
    @message = msg

    mail to: recipients, subject: sub, reply_to: @source_agent.email,
      tag: 'sent_residential_listings', track_opens:'true'
  end

  def send_commercial_listings(source_agent_id, listing_ids, recipients, sub, msg)
    @source_agent = User.where(id: source_agent_id).first
    @listings = CommercialListing.listings_by_id(@source_agent, listing_ids)
    @images = CommercialListing.get_images(@listings)
    @message = msg

    mail to: recipients, subject: sub, reply_to: @source_agent.email,
        tag: 'sent_commercial_listings', track_opens:'true'
  end

  def send_sales_listings(source_agent_id, listing_ids, recipients, sub, msg)
    @source_agent = User.where(id: source_agent_id).first
    @listings = SalesListing.listings_by_id(@source_agent, listing_ids)
    @images = SalesListing.get_images(@listings)
    @source_agent = source_agent
    @message = msg

    mail to: recipients, subject: sub, reply_to: @source_agent.email,
        tag: 'sent_sales_listings', track_opens:'true'
  end

  def send_stale_listings_report(managers, data)
    @data = data
    mail to: managers, subject: "Stale Listings Report",
        tag: 'stale_listings_report', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  def send_forced_syndication_report(managers, data)
    @data = data
    mail to: managers, subject: "Forced Syndication Listings Report",
        tag: 'forced_syndication_report', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  # managers - list of email addresses
  # data - list of addresses
  def send_clear_pending_report(managers, ids)
    @listings = ResidentialListing.joins([unit: :building])
        .where(id: ids)
        .select('buildings.street_number', 'buildings.route',
          'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
          'units.building_unit', 'residential_listings.id').to_a

    mail to: managers, subject: "Clear Pending Report",
        tag: 'clear_pending_report', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  def send_clear_pending_warning_report(managers, ids)
    @listings = ResidentialListing.joins([unit: :building])
        .where(id: ids)
        .select('buildings.street_number', 'buildings.route',
          'buildings.street_number || \' \' || buildings.route as street_address_and_unit',
          'units.building_unit', 'residential_listings.id').to_a

    mail to: managers, subject: "Clear Pending Report - Warning",
        tag: 'clear_pending_warning_report', track_opens:'true', reply_to: 'no-reply@myspacenyc.com'
  end

  def send_access_information(building,unit,rent,access_info,tenant_occupied, user_name)
    #exit
    @address = Building.find(building).formatted_street_address
    #abort @address.inspect
    street_number = Building.find(building).street_number
    route = Building.find(building).route
    @unit = unit
    @rent = rent
    @access_info = access_info
    @tenant_occupied = tenant_occupied
    @user_name = user_name
    mail(to: 'bparekh@myspacenyc.com', subject: "Access (#{street_number} #{route}##{@unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email when new unit created using add unit button
  def send_email_at_new_unit_create(building,building_unit,beds,baths,rent,residential_amenity,access_info,notes,available,has_fee,tp_fee_percentage,op_fee_percentage,lease_start,lease_end, user_name)
    @building = Building.find(building).formatted_street_address
    street_number = Building.find(building).street_number
    route = Building.find(building).route
    @building_unit = building_unit
    @beds = beds
    @baths = baths
    @rent = rent
    @all_residential_amenity = ""
    residential_amenity.each do |res_a|
      @all_residential_amenity +=  ResidentialAmenity.find(res_a).name + ","
    end
    @access_info = access_info
    @notes = notes
    @available = available
    @has_fee = has_fee
    @tp_fee_percentage = tp_fee_percentage
    @op_fee_percentage = op_fee_percentage
    @lease_start = lease_start
    @lease_end = lease_end
    @landlord = Building.find(building).landlord.code
    @user_name = user_name
    mail(to: 'bparekh@myspacenyc.com', subject: "New Unit (#{street_number} #{route}##{building_unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  # def send_email_at_new_unit_duplicate(building,building_unit,beds,baths,rent,residential_amenity,access_info,notes,available,tp_fee_percentage,op_fee_percentage,lease_start,lease_end, user_name)
  #   @building = Building.find(building).formatted_street_address
  #   street_number = Building.find(building).street_number
  #   route = Building.find(building).route
  #   @building_unit = building_unit
  #   @beds = beds
  #   @baths = baths
  #   @rent = rent
  #   @all_residential_amenity = residential_amenity
  #   @access_info = access_info
  #   @notes = notes
  #   @available = available
  #   @tp_fee_percentage = tp_fee_percentage
  #   @op_fee_percentage = op_fee_percentage
  #   @lease_start = lease_start
  #   @lease_end = lease_end
  #   @landlord = Building.find(building).landlord.code
  #   @user_name = user_name
  #   mail(to: 'rakshit@aristainfotech.com', subject: "New Unit Duplicated (#{street_number} #{route}##{building_unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  # end

  #send email when some one click on unit email button
  def send_unit_email(building,building_unit,beds,baths,rent,residential_amenity,access_info,notes,available,has_fee,tp_fee_percentage,op_fee_percentage,lease_start,lease_end, user_name)
    @building = Building.find(building).formatted_street_address
    street_number = Building.find(building).street_number
    route = Building.find(building).route
    @building_unit = building_unit
    @beds = beds
    @baths = baths
    @rent = rent
    @all_residential_amenity = ""
    residential_amenity.each do |res_a|
      @all_residential_amenity +=  ResidentialAmenity.find(res_a).name + ","
    end
    @access_info = access_info
    @notes = notes
    @available = available
    @has_fee = has_fee
    @tp_fee_percentage = tp_fee_percentage
    @op_fee_percentage = op_fee_percentage
    @lease_start = lease_start
    @lease_end = lease_end
    @landlord = Building.find(building).landlord.code
    @user_name = user_name
    mail(to: 'bparekh@myspacenyc.com', subject: "Unit Email (#{street_number} #{route}##{building_unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email when anyone change status to Off
  def send_status_off(building,building_unit,user_name)
    
    @building = Building.find(building).formatted_street_address
    street_number = Building.find(building).street_number
    route = Building.find(building).route
    @building_unit = building_unit
    @user_name = user_name
    mail(from: user_name.email ,to: 'rakshit@aristainfotech.com', subject: "Take Off (#{street_number} #{route}##{building_unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email when anyone change status to Pending
  def send_status_pending(building,building_unit,user_name)
    @building = Building.find(building).formatted_street_address
    street_number = Building.find(building).street_number
    route = Building.find(building).route
    @building_unit = building_unit
    @user_name = user_name
    mail(to: 'bparekh@myspacenyc.com', subject: "Pending (#{street_number} #{route}##{building_unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email when anyone Change Price
  def send_price_change(building,building_unit,rent,old_rent,notes,access_info,user_name)
    @building = Building.find(building).formatted_street_address
    street_number = Building.find(building).street_number
    route = Building.find(building).route
    @building_unit = building_unit
    @old_rent = old_rent
    @rent = rent
    @notes = notes
    @access_info = access_info
    @user_name = user_name
    mail(to: 'bparekh@myspacenyc.com', subject: "Price Change (#{street_number} #{route}##{building_unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email when anyone change status to Active
  def send_status_active(available,building,building_unit,rent,residential_amenity,notes,access_info,id,lease_start,lease_end,has_fee,op_fee_percentage,tp_fee_percentage, user_name)
    @available = available
    @building = Building.find(building).formatted_street_address
    street_number = Building.find(building).street_number
    route = Building.find(building).route
    @building_unit = building_unit
    @rent = rent
    @all_residential_amenity = ""
    residential_amenity.each do |res_a|
      @all_residential_amenity +=  ResidentialAmenity.find(res_a).name + ","
    end
    @notes = notes
    @access_info = access_info
    @pet_policy = ResidentialListing.find(id).unit.building.pet_policy.name
    @lease_start = lease_start
    @lease_end = lease_end
    @has_fee = has_fee
    @op_fee_percentage = op_fee_percentage
    @tp_fee_percentage = tp_fee_percentage
    @user_name = user_name
    mail(from: user_name.email,to: 'rakshit@aristainfotech.com', subject: "Back on Market (#{street_number} #{route}##{building_unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send an email when available date changed
  def send_available_by_info(building,building_unit,rent,available, user_name)
    @building = Building.find(building).formatted_street_address
    street_number = Building.find(building).street_number
    route = Building.find(building).route
    @building_unit = building_unit
    @rent = rent
    @available = available
    @user_name = user_name
    mail(to: 'bparekh@myspacenyc.com', subject: "Available (#{street_number} #{route}##{building_unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send an email when any one change any thing in listing
  def send_details_of_user_activity(building,building_unit,user_name)
    @building = Building.find(building).formatted_street_address
    street_number = Building.find(building).street_number
    route = Building.find(building).route
    @building_unit = building_unit
    @time = Time.now().strftime('%m/%d/%Y %I:%M:%S %p')
    @user_name = user_name
    mail(to: 'bparekh@myspacenyc.com', subject: "Unit Update (#{street_number} #{route}##{@building_unit})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end
  # def send_new_rental_unit_added(available,address,building_unit,rent,residential_amenities,notes,access_info,pet_policy,lease_start,lease_end, op_fee_percentage,tp_fee_percentage)
  #   @available = available
  #   @building = address
  #   @building_unit = building_unit
  #   @rent = rent
  #   @residential_amenities = residential_amenities
  #   @notes = notes
  #   @access_info = access_info
  #   @pet_policy = pet_policy
  #   @lease_start = lease_start
  #   @lease_end = lease_end
  #   @op_fee_percentage = op_fee_percentage
  #   @tp_fee_percentage = tp_fee_percentage
  #   mail(to: 'rakshit@aristainfotech.com', subject: "New Unit", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  # end

  #send email every hour at new unit added
  def send_new_rental_unit_added(residential_listing)
    @residential_listing = residential_listing
    mail(to: 'bparekh@myspacenyc.com', subject: "New Unit", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email at the end of Day how many new unit added
  def send_new_rental_unit_added_of_the_day(residential_listing)
    @residential_listing = residential_listing
    mail(to: 'bparekh@myspacenyc.com', subject: "New Unit", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email at the end of the day for total Off status unit
  def send_take_off_of_the_day(day_list)
    @day_list = day_list
    #abort @day_list[404].inspect
    @day_off_list = []
    @day_list.each do |day_list|
      if day_list.audited_changes.to_a[0][0] == "status"
        if day_list.audited_changes.to_a[0][1][1] == "off"
          @day_off_list << day_list
        end
      end
    end
    mail(to: 'bparekh@myspacenyc.com', subject: "Take Off", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email at the end of the day for total Pending status unit
  def send_pending_of_the_day(day_list)
    @day_list = day_list
    #abort @day_list[404].inspect
    @day_off_list = []
    @day_list.each do |day_list|
      if day_list.audited_changes.to_a[0][0] == "status"
        if day_list.audited_changes.to_a[0][1][1] == "pending"
          @day_off_list << day_list
        end
      end
    end
    mail(to: 'bparekh@myspacenyc.com', subject: "Pending", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email at the end of the day for total Active status unit
  def send_back_on_market_of_the_day(day_list)
    @day_list = day_list
    #abort @day_list[404].inspect
    @day_off_list = []
    @day_list.each do |day_list|
      if day_list.audited_changes.to_a[0][0] == "status"
        if day_list.audited_changes.to_a[0][1][1] == "active"
          @day_off_list << day_list
        end
      end
    end
    mail(to: 'bparekh@myspacenyc.com', subject: "Back On Market", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  #send email at the end of the day for total Active status unit
  def send_price_change_of_the_day(day_list)
    @day_list = day_list
    #abort @day_list[412].inspect
    @day_off_list = []
    @day_list.each do |day_list|
      #abort day_list.audited_changes.include?("rent").inspect
      if day_list.audited_changes.include?("rent") == true
          @day_off_list << day_list
      end
    end
    #@day_off_list = @day_off_list.uniq{|x| x.auditable_id}
    #abort @day_off_list.uniq{|x| x.auditable_id}.count.inspect
    mail(to: 'bparekh@myspacenyc.com', subject: "Price Change", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end

  def send_email_at_claim_for_streeteasy(listing,user)
    @listing_street_number = listing.unit.building.street_number
    @listing_route = listing.unit.building.route
    @listing_unit_number = listing.unit.building_unit
    @listing_address = @listing_street_number + " " + @listing_route + " #" + @listing_unit_number
    @user = user
    mail(to: @user.email, subject: "Claim for Streeteasy (#{@listing_address})", track_opens:'true', reply_to: 'no-reply@myspacenyc.com')
  end
end
