class Landlord < ActiveRecord::Base
	has_many :buildings

	enum months_required: [:first_month, :last_month, :first_and_last_months]

	validates :code, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

	validates :name, presence: true, length: {maximum: 100}, 
		uniqueness: { case_sensitive: false }

	VALID_TELEPHONE_REGEX = /(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?/
	validates :mobile, presence: true, length: {maximum: 20}, 
		format: { with: VALID_TELEPHONE_REGEX }
	validates :phone, presence: true, length: {maximum: 20}, 
		format: { with: VALID_TELEPHONE_REGEX }
	validates :fax, presence: true, length: {maximum: 20}, 
		format: { with: VALID_TELEPHONE_REGEX }

	before_save :downcase_email
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 100}, 
		format: { with: VALID_EMAIL_REGEX }, 
    uniqueness: { case_sensitive: false }

	validates :months_required, presence: true, length: {maximum: 100}
	
	def active_units
		buildings.reduce(0){|sum, bldg| sum + bldg.active_units.count }
	end

	def total_units
		buildings.reduce(0){|sum, bldg| sum + bldg.units.count }
	end

	def last_unit_updated_on
		return '-' # TODO
	end	

	private
    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end
	
end
