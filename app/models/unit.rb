class Unit < ActiveRecord::Base
	belongs_to :building, touch: true
  belongs_to :primary_agent, :class_name => 'User', touch: true
  belongs_to :primary_agent2, :class_name => 'User', touch: true
  has_many :images, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_one :residential_listing, dependent: :destroy
  has_one :commercial_listing, dependent: :destroy
  has_one :sales_listing, dependent: :destroy
  before_validation :generate_unique_id

  scope :unarchived, ->{ where(archived: false) }
  scope :active, ->{ where(status: Unit.statuses["active"]) }
  scope :on_market, ->{ where(status: [Unit.statuses["active"], Unit.statuses["pending"]]) }
  
	enum status: [ 
    :active, :pending, :off, #residential
    :offer_submitted, :offer_accepted, :binder_signed, :off_market_for_lease_execution #commercial
   ]
  
	validates :status, presence: true, inclusion: { 
    in: ['active', 'pending', 'off', 
         'offer_submitted', 'offer_accepted', 'binder_signed', 'off_market_for_lease_execution'] }
	
	validates :rent, presence: true, numericality: { only_integer: true }
	validates :listing_id, presence: true, uniqueness: true
	
  validates :building_id, presence: true
  validates :building_unit, allow_blank: true, length: {maximum: 50}

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

  # returns all images for each unit
  def self.get_all_images(list)
    unit_ids = list.map(&:unit_id)
    Image.where(unit_id: unit_ids).to_a.group_by(&:unit_id)
  end

  # Used by Nestio API
  def self.get_primary_agents(list)
    agent_ids = list.map(&:primary_agent_id)
    User.joins(:office).where(id: agent_ids)
      .select('id', 'name', 'email', 'mobile_phone_number', 'phone_number', 'public_url',
        'offices.telephone AS office_telephone', 'offices.fax AS office_fax')
      .to_a.group_by(&:id)
  end

  # Used by streeteasy API
  def self.get_primary_agents_and_images(list)
    agent_ids = list.map(&:primary_agent_id)
    users = User.joins(:office).where(id: agent_ids)
      .select('id', 'name', 'email', 'mobile_phone_number', 'phone_number', 'public_url',
        'offices.telephone AS office_telephone', 'offices.fax AS office_fax')
      .to_a.group_by(&:id)


    images = Image.where(user_id: agent_ids).index_by(&:user_id)

    return [users, images]
  end

  # Used by API
  def self.get_pet_policies(list)
    bldg_ids = list.map(&:building_id)
    Building.joins(:pet_policy).where(id: bldg_ids)
      .select('buildings.id', 'pet_policies.name as pet_policy_name')
      .to_a.group_by(&:id)
  end

  # mainly for use in our API. Returns list of any
  # agent contacts for this listing. Currently we have
  # 1 primary agent for each listing, but could change in the future.
  def contacts
    # TODO: commercial has 2
    contacts = [primary_agent];
  end

  private
    # TODO: code review - should only be set if none exists
    def generate_unique_id
      if !listing_id
        #puts "*** calling generate"
        #if !self.unit.listing_id
          listing_id = SecureRandom.random_number(9999999)
          while Unit.find_by(listing_id: listing_id) do
            listing_id = SecureRandom.random_number(9999999)
          end

          self.listing_id = listing_id
      end
    end

end