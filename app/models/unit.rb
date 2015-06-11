class Unit < ActiveRecord::Base
	actable
	belongs_to :building

  scope :unarchived, ->{where(archived: false)}
  scope :active, ->{where(status: "active")}
  
  # TODO: test. I don't think this is working right
	belongs_to :primary_agent, :foreign_key => 'user_id', :class_name => 'User'
	belongs_to :listing_agent, :foreign_key => 'user_id', :class_name => 'User'

	enum status: [ :active, :pending, :off ]
	validates :status, presence: true, inclusion: { in: %w(active pending off) }
	
	#validates :building_unit, presence: true, length: {maximum: 50}
	validates :rent, presence: true, numericality: { only_integer: true }
	validates :listing_id, presence: true, uniqueness: true
	
  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

	def self.get_residential(units)
    running_list = units.where("actable_type = 'ResidentialUnit'")
    running_list = running_list.uniq
    ids = running_list.map(&:id)

    residential_units = ResidentialUnit.where(id: ids)
    residential_units
  end

  def self.get_commercial(units)
    running_list = units.where("actable_type = 'CommercialUnit'")
    running_list = running_list.uniq
    ids = running_list.map(&:id)

    commercial_units = CommercialUnit.where(id: ids)
    commercial_units
  end

	def self.generate_unique_id
		listing_id = SecureRandom.random_number(9999999)
    while ResidentialUnit.find_by(listing_id: listing_id) do
      listing_id = rand(9999999)
    end
    listing_id
  end
	
end