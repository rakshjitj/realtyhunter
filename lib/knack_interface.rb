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

    def self.send_request(data, url)
      # don't send dev/test data
     return unless Rails.env.production?

      data.each do |k, v|
        data.delete(k) unless !data[k].nil?
      end

      uri = URI.parse(url)
      request = Net::HTTP::Post.new(uri)
      HEADERS.each do |k, v|
        request[k] = v
      end
      request.body = data.to_json
      # puts request.body

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection

        json_response = JSON.parse(res.body)
        puts 'SUCCESS - Received Knack ID ' + json_response['id']
        {id: json_response['id']}
      else
        puts res.body.inspect
      end
    end

    def self.pull_request(url)
      uri = URI.parse(url)
      request = Net::HTTP::Get.new(uri)
      HEADERS.each do |k, v|
        request[k] = v
      end
      # puts request.body

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection

        json_response = JSON.parse(res.body)
        puts "SUCCESS - Received Knack records for #{url}"
        json_response
        # puts json_response['records'].inspect
        #{ records: json_response['records']}
      else
        puts res.body.inspect
      end
    end
  end

  class CreateLandlord < KnackBase
    @queue = :knack

    def self.perform(landlord_id)
      landlord = Landlord.where(id: landlord_id).first
      data = {
        field_95:  landlord.code, # ll code
        field_96:  landlord.name, # company
        field_342: !landlord.formatted_street_address.blank? ? landlord.formatted_street_address : '-None-', # address,
        field_345: landlord.contact_name, # contacts
        field_347: landlord.office_phone, # contact phone number
        field_357: landlord.mobile, # optional: contact mobile
        # field_346: landlord.contact_name, # optional: office contact -- TODO: What is this?
        # field_103: landlord.office_phone, # optional: Office Phone
        field_100: !landlord.email.blank? ? landlord.email : nil, # optional: Email
        field_348: !landlord.fax.blank? ? landlord.fax : nil, # optional: fax
        # field_349: '', # optional: Office Contact 2
        # field_104: '', # optional: Phone 2
        # field_101: '', # optional: Email 2
        # field_344: '', # optional: Additional Management info
        field_351: !landlord.website.blank? ? landlord.website : nil, # optional: Website
        field_358: landlord.op_fee_percentage, # optional: OP
      }

      knack_response = send_request(data, LANDLORD_URL)
      if knack_response[:id]
        landlord.update_attribute(:knack_id, knack_response[:id])
      end
    end
  end

  class CreateBuilding < KnackBase
    @queue = :knack

    def self.perform(building_id)
      building = Building.where(id: building_id).first
      data = {
        field_134: building.landlord.knack_id, # landlord connection,
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
        # field_710: building. # optional: Listing Agent
        # field_711: building.landlord.name, # optional: Listing Landlord
        # field_719: building. # optional: Building Op
        # field_852: # optional: Building Manager
      }

      knack_response = send_request(data, BUILDING_URL)
      if knack_response[:id]
        building.update_attribute(:knack_id, knack_response[:id])
      end
    end
  end

  class CreateResidentialListing < KnackBase
    @queue = :knack

    def self.perform(listing_id)
      listing = ResidentialListing.where(id: listing_id).first
      data = {
        field_387: listing.unit.building.knack_id, # building connection
        field_137: listing.unit.building_unit, # unit number
        field_140: listing.beds == 0 ? 'Studio' : listing.beds, # Bedroom Count
        field_146: listing.baths, # optional: Bathroom
        field_141: listing.unit.rent, # Rent
        field_700: listing.op_fee_percentage # Unit OP
      }

      knack_response = send_request(data, RESIDENTIAL_LISTING_URL)
      if knack_response[:id]
        listing.update_attribute(:knack_id, knack_response[:id])
      end
    end
  end

  class GetLandlordIds < KnackBase
    @queue = :knack

    def self.perform
      knack_response = pull_request(LANDLORD_URL)

      while knack_response["current_page"].to_i < knack_response["total_pages"].to_i do
        if knack_response["records"]
          records = knack_response["records"]
          records.each do |record|
            code = record["field_95"]
            landlord = Landlord.where(code: code).first
            if landlord
              landlord.update_attribute(:knack_id, record["id"])
              puts "UPDATED #{landlord.code} #{landlord.knack_id}"
            else
              puts "Skipping: Landlord not found with code #{code}"
            end
          end
        end
        new_page = knack_response[:current_page].to_i + 1
        knack_response = pull_request(LANDLORD_URL + "?page=#{new_page}&rows_per_page=1000")
      end
    end
  end

  class GetBuildingIds < KnackBase
    @queue = :knack

    def self.perform
      knack_response = pull_request(BUILDING_URL)

      while knack_response["current_page"].to_i < knack_response["total_pages"].to_i do
        if knack_response["records"]
          records = knack_response["records"]
          records.each do |record|
            address = record["field_745_raw"]["street"]
            building = Building
              .where('buildings.formatted_street_address ILIKE ?', "%#{address}%")
              .first
            if building
              building.update_attribute(:knack_id, record["id"])
              puts "UPDATED #{building.formatted_street_address} #{building.knack_id}"
            else
              puts "Skipping: Building not found with address #{address}"
            end
          end
        end
        new_page = knack_response[:current_page].to_i + 1
        knack_response = pull_request(BUILDING_URL + "?page=#{new_page}&rows_per_page=1000")
      end
    end
  end

  # Note:
  # A reponse error code 429 means we are over our API limits.
  # When that happens, we should notify our staff.
end
