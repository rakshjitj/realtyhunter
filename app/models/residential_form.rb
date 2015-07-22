class ResidentialForm
	include ActiveModel::Model

	UNIT_ATTRIBUTES = [*Unit.new.attributes.keys, *Unit.reflect_on_all_associations.collect {|a| a.name.to_s}]
	RESIDENTIAL_ATTRIBUTES = [*ResidentialListing.new.attributes.keys, 
		*ResidentialListing.reflect_on_all_associations.collect {|a| a.name.to_s},
		"residential_amenity_ids"]
	
	def persisted?
		!id.nil?
	end

	attr_accessor *RESIDENTIAL_ATTRIBUTES
  attr_accessor *UNIT_ATTRIBUTES
  
  def attributes
    [*UNIT_ATTRIBUTES, *RESIDENTIAL_ATTRIBUTES].each_with_object({}) do |x, hash|
      hash[x] = send x

    end
  end

  attr_accessor :listing

  def create
  	if valid?

  		puts "\n\nVALID"

  		# if updating
  		#if persisted?
  			listing = ResidentialListing.find(id)
  			if listing
	  			puts "CREATING"
	  			#unit = unit.create!(attributes.slice(UNIT_ATTRIBUTES))
	  			#listing.create!(attributes.slice(RESIDENTIAL_ATTRIBUTES))
				end 
			#end
		else
			# TODO
		end

  end

  # hack id
  def update(params_id)

  	if valid?
  		puts "\n\nVALID"
  		# if updating
  		#if persisted?
			listing = ResidentialListing.find(params_id)
			if listing
  			puts "UPDATING"
  			r_attrs = attributes.slice(*RESIDENTIAL_ATTRIBUTES).delete_if { |k, v| v.nil? }
  			listing.update(r_attrs)
  			listing.unit.update(attributes.slice(*UNIT_ATTRIBUTES).delete_if { |k, v| v.nil? })
			end  			
    	true
    else
    	# validation failed!
    	puts "\n\nNOPEE"
    	false
    end
  end

  def self.load(id)
  	residential_listing = ResidentialListing.find(id)
  	puts residential_listing.attributes.inspect

		form = ResidentialForm.new(residential_listing.unit.attributes.merge(residential_listing.attributes))
		form.listing = residential_listing
		form
  end

	# from unit
	validates :status, presence: true, inclusion: { in: %w(active pending off) }
  #validates :building, presence: true

  # from residential_listing
  validates :building_unit, presence: true, length: {maximum: 50}
	validates :lease_start, presence: true, length: {maximum: 5}
  validates :lease_end, presence: true, length: {maximum: 5}
  validates :rent, presence: true, :numericality => { :greater_than => 0 }
	validates :beds, presence: true, :numericality => { :less_than_or_equal_to => 11 }
	validates :baths, presence: true, :numericality => { :less_than_or_equal_to => 11 }
  validates :op_fee_percentage, allow_blank: true, length: {maximum: 3}#, numericality: { only_integer: true }
  #validates_inclusion_of :op_fee_percentage, :in => 0..100
  validates :tp_fee_percentage, allow_blank: true, length: {maximum: 3}#, numericality: { only_integer: true }
  #validates_inclusion_of :tp_fee_percentage, :in => 0..100

end