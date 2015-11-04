class Office < ActiveRecord::Base
	belongs_to :company, touch: true
	has_many :users

	scope :unarchived, ->{where(archived: false)}
	default_scope { order("name ASC") }

	validates :company, presence: true
	
	validates :name, presence: true, length: {maximum: 100}, 
						uniqueness: { case_sensitive: false }

	# Google Maps location info
	validates :formatted_street_address, presence: true, length: {maximum: 200}, 
						uniqueness: { case_sensitive: false }
						
	validates :street_number, presence: true, length: {maximum: 20}
	validates :route, presence: true, length: {maximum: 100}
	# borough
	#:sublocality can be blank
	# city
	validates :administrative_area_level_2_short, presence: true, length: {maximum: 100}
	# state
	validates :administrative_area_level_1_short, presence: true, length: {maximum: 100}
	validates :postal_code, presence: true, length: {maximum: 15}
	validates :country_short, presence: true, length: {maximum: 100}
	validates :lat, presence: true, length: {maximum: 100}
	validates :lng, presence: true, length: {maximum: 100}
	validates :place_id, presence: true, length: {maximum: 100}

	# Other options: strip all formatting out and save as raw string of digits.
	# Format on the front end.
	VALID_TELEPHONE_REGEX = /(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?/
	validates :telephone, presence: true, length: {maximum: 20}, 
						format: { with: VALID_TELEPHONE_REGEX }

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

	def managers
		User.joins([:office, :employee_title]).merge(Office.where(id: self.id))
			.includes(:subordinates)
			.unarchived
			.merge(EmployeeTitle.where(name: 'manager'))
			.order(:name)
			.select('users.company_id', 'users.archived', 'users.id', 
        'users.name', 'users.email', 'users.activated', 'users.approved', 'users.last_login_at',
        'employee_titles.id AS employee_title_id',
        'employee_titles.name AS employee_title_name',
        'offices.name AS office_name', 'offices.id as office_id',
        'users.manager_id')
	end

	def agents
		User.joins(:office, :employee_title)
			.includes(:manager, :roles)
			.unarchived
			.merge(Office.where(id: self.id))
			.merge(EmployeeTitle.where(name: 'agent'))
			.order(:name)
			.select('users.company_id', 'users.archived', 'users.id', 
        'users.name', 'users.email', 'users.activated', 'users.approved', 'users.last_login_at',
        'employee_titles.id AS employee_title_id',
        'employee_titles.name AS employee_title_name',
        'offices.name AS office_name', 'offices.id as office_id',
        'users.manager_id')
	end
end
