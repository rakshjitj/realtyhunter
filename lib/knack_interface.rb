module KnackInterface
  require "uri"
  require "net/http"

  class KnackBase
    APPLICATION_ID = '582e6f12c2dc30792f37384d'
    API_KEY = '3d8e7790-9c8f-48a2-bcff-3a41c11de66b'
    LANDLORD_URL = "https://api.knack.com/v1/objects/object_18/records"
    BUILDING_URL = "https://api.knack.com/v1/objects/object_22/records"
    RESIDENTIAL_LISTING_URL = "https://api.knack.com/v1/objects/object_23/records"
    HEADERS = {
      'X-Knack-Application-Id': APPLICATION_ID,
      'X-Knack-REST-API-Key': API_KEY,
      'content-type': 'application/json'
    }

    def self.knack_request(request_type, url, data = nil)
      # don't send dev/test data
      # return {} unless Rails.env.production?

      uri = URI.parse(url)
      if request_type == 'create'
        request = Net::HTTP::Post.new(uri)
      elsif request_type == 'update'
        request = Net::HTTP::Put.new(uri)
      else
        request = Net::HTTP::Get.new(uri)
      end

      HEADERS.each do |k, v|
        request[k] = v
      end

      if request_type != 'get'
        data.each do |k, v|
          data.delete(k) unless !data[k].nil?
        end
        request.body = data.to_json
        # puts request.body
      end

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        json_response = JSON.parse(res.body)
        json_response
      else
        puts res.body.inspect
      end
    end

    def self.create_request(url, data)
      json_response = self.knack_request('create', url, data)
      if json_response['id']
        puts 'SUCCESS - Received Knack ID ' + json_response['id']
      else
        puts 'ERROR ' + json_response.inspect
      end
      {id: json_response['id']}
    end

    def self.update_request(url, data)
      json_response = self.knack_request('update', url, data)
      if json_response['id']
        puts 'SUCCESS - Received Knack ID ' + json_response['id']
      else
        puts 'ERROR ' + json_response.inspect
      end
      {id: json_response['id']}
    end

    def self.get_request(url)
      json_response = self.knack_request('get', url)
      puts "SUCCESS - Received Knack records for #{url}"
      json_response
    end
  end

  class CreateLandlord < KnackBase
    @queue = :knack

    def self.perform(landlord_id)
      landlord = Landlord.where(id: landlord_id).first
      return if landlord.knack_id # its already been created
      puts "Creating landlord..."

      data = {
        field_95:  landlord.code, # ll code
        field_96:  landlord.name, # company
        field_342: !landlord.formatted_street_address.blank? ? landlord.formatted_street_address : '-None-', # address,
        field_345: landlord.contact_name ? landlord.contact_name : '-None-', # contacts
        field_347: landlord.office_phone ? landlord.office_phone : '-None-', # contact phone number
        field_357: landlord.mobile, # optional: contact mobile
        # field_346: landlord.contact_name, # optional: office contact (extra, not used in RH)
        # field_103: landlord.office_phone, # optional: Office Phone (extra, not used in RH)
        field_100: !landlord.email.blank? ? landlord.email : nil, # optional: Email
        field_348: !landlord.fax.blank? ? landlord.fax : nil, # optional: fax
        # field_349: '', # optional: Office Contact 2 (extra, not used in RH)
        # field_104: '', # optional: Phone 2 (extra, not used in RH)
        # field_101: '', # optional: Email 2 (extra, not used in RH)
        # field_344: '', # optional: Additional Management info
        field_351: !landlord.website.blank? ? landlord.website : nil, # optional: Website
        field_358: landlord.op_fee_percentage, # optional: OP
      }

      knack_response = self.create_request(LANDLORD_URL, data)
      if knack_response[:id]
        landlord.update_column(:knack_id, knack_response[:id])
      end
    end
  end

  class UpdateLandlord < KnackBase
    @queue = :knack

    def self.perform(landlord_id)
      landlord = Landlord.where(id: landlord_id).first

      data = {
        field_95:  landlord.code, # ll code
        field_96:  landlord.name, # company
        field_342: !landlord.formatted_street_address.blank? ? landlord.formatted_street_address : '-None-', # address,
        field_345: landlord.contact_name ? landlord.contact_name : '-None-', # contacts
        field_347: landlord.office_phone ? landlord.office_phone : '-None-', # contact phone number
        field_357: landlord.mobile, # optional: contact mobile
        field_100: !landlord.email.blank? ? landlord.email : nil, # optional: Email
        field_348: !landlord.fax.blank? ? landlord.fax : nil, # optional: fax
        field_351: !landlord.website.blank? ? landlord.website : nil, # optional: Website
        field_358: landlord.op_fee_percentage, # optional: OP
      }

      knack_response = update_request(LANDLORD_URL + '/' + landlord.knack_id, data)
    end
  end

  class CreateBuilding < KnackBase
    @queue = :knack

    def self.perform(building_id)
      building = Building.where(id: building_id).first
      # If we have missing data, create it in Knack first
      if !building.landlord.knack_id
        cl = CreateLandlord
        cl.perform(building.landlord.id)
      end
      return if building.knack_id # its already been created
      puts "Creating building..."

      data = {
        field_134: [building.landlord.knack_id], # landlord connection,
        field_124: building.llc_name, # optional: LLC Name
        field_745: { # Address 1
          street: building.street_number + building.route,
          city: building.sublocality,
          state: building.administrative_area_level_1_short,
          zip: building.postal_code
        },
        field_120: "#{building.total_unit_count}", # Number Of Units
        field_359: building.neighborhood ? building.neighborhood.name : '-None-', # Neighborhood
        field_690: building.notes, # optional: Note
        # field_710: building. # optional: Listing Agent (manually entered, not used here)
        # field_711: building.landlord.name, # optional: Listing Landlord (manually entered, not used here)
        # field_719: building. # optional: Building Op
        # field_852: # optional: Building Manager
      }

      knack_response = create_request(BUILDING_URL, data)
      if knack_response[:id]
        building.update_column(:knack_id, knack_response[:id])
      end
    end
  end

  class UpdateBuilding < KnackBase
    @queue = :knack

    def self.perform(building_id)
      building = Building.where(id: building_id).first
      # If we have missing data, create it in Knack first
      if !building.landlord.knack_id
        cl = CreateLandlord
        cl.perform(building.landlord.id)
      end

      data = {
        field_134: [building.landlord.knack_id], # landlord connection,
        field_124: building.llc_name, # optional: LLC Name
        field_745: { # Address 1
          street: building.street_number + building.route,
          city: building.sublocality,
          state: building.administrative_area_level_1_short,
          zip: building.postal_code
        },
        field_120: "#{building.total_unit_count}", # Number Of Units
        field_359: building.neighborhood ? building.neighborhood.name : '-None-', # Neighborhood
        field_690: building.notes, # optional: Note
      }

      knack_response = update_request(BUILDING_URL + '/' + building.knack_id, data)
    end
  end

  class CreateResidentialListing < KnackBase
    @queue = :knack

    def self.perform(listing_id, is_now_active=nil)
      listing = ResidentialListing.where(id: listing_id).first
      # If we have missing data, create it in Knack first
      if !listing.unit.building.knack_id
        cb = CreateBuilding
        cb.perform(listing.unit.building.id)
      end
      return if listing.knack_id # its already been created
      puts "Creating residential listing..."

      if listing.unit.status == 'active'
        status = 'Activated'
      elsif listing.unit.status == 'pending'
        status = 'Pending'
      else
        status = 'Deactivated'
      end

      data = {
        field_387: [listing.unit.building.knack_id], # building connection
        field_137: listing.unit.building_unit, # unit number
        field_140: listing.beds == 0 ? 'Studio' : listing.beds, # Bedroom Count
        field_146: listing.baths, # Bathroom
        field_141: listing.unit.rent, # Rent
        field_700: listing.op_fee_percentage, # Unit OP
        field_880: status # status
      }

      if is_now_active
        # optional: date listing became 'active' mm/dd/yyyy
        data[:field_878] = Date.today.strftime("%m/%d/%Y")
      elsif !is_now_active.nil? && !is_now_active
        # optional: date listing went off market mm/dd/yyyy
        data[:field_879] = Date.today.strftime("%m/%d/%Y")
      end

      knack_response = create_request(RESIDENTIAL_LISTING_URL, data)
      if knack_response[:id]
        listing.update_column(:knack_id, knack_response[:id])
      end
    end
  end

  class UpdateResidentialListing < KnackBase
    @queue = :knack

    def self.perform(listing_id, is_now_active=nil)
      listing = ResidentialListing.where(id: listing_id).first

      # If we have missing data, create it in Knack first
      if !listing.unit.building.knack_id
        cb = CreateBuilding
        cb.perform(listing.unit.building.id)
      end
      return unless listing.knack_id # don't update knack unless it exists

      if listing.unit.status == 'active'
        status = 'Activated'
      elsif listing.unit.status == 'pending'
        status = 'Pending'
      else
        status = 'Deactivated'
      end

      data = {
        field_387: [listing.unit.building.knack_id], # building connection
        field_137: listing.unit.building_unit, # unit number
        field_140: listing.beds == 0 ? 'Studio' : listing.beds, # Bedroom Count
        field_146: listing.baths, # Bathroom
        field_141: listing.unit.rent, # Rent
        field_700: listing.op_fee_percentage, # Unit OP
        field_880: status # status
      }

      if is_now_active
        # optional: date listing became 'active' mm/dd/yyyy
        data[:field_878] = Date.today.strftime("%m/%d/%Y")
      elsif !is_now_active.nil? && !is_now_active
        # optional: date listing went off market mm/dd/yyyy
        data[:field_879] = Date.today.strftime("%m/%d/%Y")
      end

      knack_response = update_request(RESIDENTIAL_LISTING_URL + '/' + listing.knack_id, data)
    end
  end

  class GetLandlordIds < KnackBase
    @queue = :knack

    def self.perform
      knack_response = get_request(LANDLORD_URL + "?page=1&rows_per_page=1000")

      while knack_response["current_page"].to_i < (knack_response["total_pages"].to_i + 1) do
        if knack_response["records"]
          records = knack_response["records"]
          records.each do |record|
            code = record["field_95"]
            landlord = Landlord.where('code ILIKE ?', "%#{code}%").first
            if landlord
              landlord.update_column(:knack_id, record["id"])
              puts "UPDATED #{landlord.code} - #{landlord.knack_id}"
            else
              puts "Skipping: Landlord not found with code #{code}"
            end
          end
        end
        new_page = knack_response["current_page"].to_i + 1
        knack_response = get_request(LANDLORD_URL + "?page=#{new_page}&rows_per_page=1000")
      end
    end
  end

  class GetBuildingIds < KnackBase
    @queue = :knack

    def self.perform
      knack_response = get_request(BUILDING_URL + "?page=1&rows_per_page=1000")

      while knack_response["current_page"].to_i < (knack_response["total_pages"].to_i + 1) do
        # puts "#{knack_response["current_page"].to_i} #{knack_response["total_pages"].to_i}"
        if knack_response["records"]
          records = knack_response["records"]
          records.each do |record|
            original_address = record["field_745_raw"]["street"]
            address = record["field_745_raw"]["street"].strip
            # sometimes route and formatted_street_address differ in terms of abbreviations
            building = Building
              .where('buildings.formatted_street_address ILIKE ?', "%#{address}%")
              .first
            if !building
              building = Building
                .where('buildings.route ILIKE ?', "%#{address}%")
                .first
            end

            # see if replacements help
            substitutions = [
              ['Street', 'St'],
              ['Place', 'Pl'],
              ['Road', 'Rd'],
              ['Avenue', 'Ave'],
              ['Boulevard', 'Blvd'],
              ['Parkway', 'Pkwy'],
              ['East', 'E'],
              ['North', 'N'],
              ['South', 'S'],
              ['West', 'W'],
              ['Saint', 'St']
            ]

            i = 0
            while !building && i < substitutions.length do
              if !building
                address.sub!(substitutions[i][0], substitutions[i][1])
                building = Building
                  .where('buildings.formatted_street_address ILIKE ?', "%#{address}%")
                  .first
              end
              # sometimes route and formatted_street_address differ in terms of abbreviations
              if !building
                building = Building
                  .where('buildings.route ILIKE ?', "%#{address}%")
                  .first
              end
              i += 1
            end

            if building
              building.update_column(:knack_id, record["id"])
              puts "UPDATED #{building.formatted_street_address} - #{building.knack_id}"
            else

              puts "Skipping: Building not found with address [#{original_address}] or [#{address}]"
            end
          end
        end
        new_page = knack_response["current_page"].to_i + 1
        # puts "new page req #{new_page}"
        knack_response = get_request(BUILDING_URL + "?page=#{new_page}&rows_per_page=1000")
      end
    end
  end

  class GetResidentialListingIds < KnackBase
    @queue = :knack

    def self.perform
      knack_response = get_request(RESIDENTIAL_LISTING_URL + "?page=1&rows_per_page=1000")

      while knack_response["current_page"].to_i < (knack_response["total_pages"].to_i + 1) do
        # puts "#{knack_response["current_page"].to_i} #{knack_response["total_pages"].to_i}"
        if knack_response["records"]
          records = knack_response["records"]
          records.each do |record|
            building_knack_id = record["field_387_raw"][0]["id"]
            building_address = record["field_387_raw"][0]["identifier"].strip # building address
            idx = building_address.index('<br')
            building_address = building_address.slice(0, idx)
            building_unit = record["field_137_raw"].strip

            listing = ResidentialListing.joins(unit: :building)
              .where('units.building_unit = ?', building_unit)
              .where('buildings.knack_id =  ?', building_knack_id)
              .first
            if listing
              listing.update_column(:knack_id, record["id"])
              puts "UPDATED #{listing.unit.building.formatted_street_address} ##{building_unit} - #{building_knack_id}"
            else
              puts "Skipping: Residential Listings not found with address #{building_address} #{building_unit} - #{building_knack_id}"
            end
          end
        end
        new_page = knack_response["current_page"].to_i + 1
        # puts "new page req #{new_page}"
        knack_response = get_request(RESIDENTIAL_LISTING_URL + "?page=#{new_page}&rows_per_page=1000")
      end
    end
  end

  # Note:
  # A reponse error code 429 means we are over our API limits.
  # When that happens, we should notify our staff.
end
