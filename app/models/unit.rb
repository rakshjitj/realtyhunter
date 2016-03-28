class Unit < ActiveRecord::Base
	belongs_to :building, touch: true
  belongs_to :primary_agent, class_name: 'User', touch: true
  belongs_to :primary_agent2, class_name: 'User', touch: true
  has_many :images, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_one :residential_listing, dependent: :destroy
  has_one :commercial_listing, dependent: :destroy
  has_one :sales_listing, dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :deals, dependent: :destroy
  has_many :open_houses, dependent: :destroy
  accepts_nested_attributes_for :open_houses, allow_destroy: true

  before_validation :generate_unique_id

  scope :unarchived, ->{ where(archived: false) }
  scope :active, ->{ where(status: Unit.statuses["active"]) }
  scope :available_on_market, ->{ where("status = ? OR status = ?", Unit.statuses["active"], Unit.statuses["pending"]) }

	enum status: [
    :active, :pending, :off, #residential
    :offer_submitted, :offer_accepted, :binder_signed, :off_market_for_lease_execution, #additional for commercial
    :on_market, :contract_out, :in_escrow, :closed # additional for sales
   ]

	validates :status, presence: true, inclusion: {
    in: ['active', 'pending', 'off',
         'offer_submitted', 'offer_accepted', 'binder_signed', 'off_market_for_lease_execution',
         'on_market', 'contract_out', 'in_escrow', 'closed'] }

  # this should really been called "price", as its used across both rentals and sales
	validates :rent, presence: true, numericality: { only_integer: true }

	validates :listing_id, presence: true, uniqueness: true

  # sales/commercial might not have one yet
  #validates :public_url, presence: true, uniqueness: true

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

  def self.get_open_houses(list)
    unit_ids = list.map(&:unit_id)
    OpenHouse.where(unit_id: unit_ids).to_a.group_by(&:unit_id)
  end

  def self.get_primary_agents(list)
    User.joins(:office)
      .joins('inner join units on users.id = units.primary_agent_id OR users.id = units.primary_agent2_id')
      .where('units.id IN (?)', list.map(&:unit_id))
      .select('users.id', 'name', 'email', 'mobile_phone_number', 'phone_number', 'public_url',
        'offices.telephone AS office_telephone', 'offices.fax AS office_fax', 'units.id as unit_id')
      .to_a.group_by(&:unit_id)
  end

  # Used by syndication
  def self.get_primary_agents_and_images(list)
    users = User
      .joins(:office)
      .joins('inner join units on users.id = units.primary_agent_id OR users.id = units.primary_agent2_id')
      .where('units.id IN (?)', list.map(&:unit_id))
      .select('users.id', 'name', 'email', 'mobile_phone_number', 'phone_number', 'public_url',
        'offices.telephone AS office_telephone', 'offices.fax AS office_fax', 'units.id as unit_id')
      .to_a

    images = Image.where(user_id: users.map(&:id)).index_by(&:user_id)

    return [users.group_by(&:unit_id), images]
  end

  # mainly for use in our API. Returns list of any
  # agent contacts for this listing. Currently we have
  # 1 primary agent for each listing, but could change in the future.
  def contacts
    # TODO: commercial has 2
    contacts = [primary_agent];
  end

  def mark_app_submitted(user, category, status)
    self.update(status: Unit.statuses[status])
    announcement = Announcement.create({
      category: Announcement.categories['residential'],
      note: 'Application submitted on ' + self.building.street_address,
      user_id: user.id
      })
    announcement.broadcast(user)
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
          self.public_url = "http://myspacenyc.com/listing/MYSPACENYC-#{listing_id}"
      end

    end

end
