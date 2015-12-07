class RoomsharingApplication < ActiveRecord::Base
	belongs_to :user, dependent: :destroy
	#has_one :unit, dependent: :destroy

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  VALID_TELEPHONE_REGEX = /\A(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?\z/

	validates :f_name, presence: true, length: {maximum: 100}
	validates :l_name, presence: true, length: {maximum: 100}
	validates :ssn, presence: true, length: {maximum: 50}
	validates :dob, presence: true, length: {maximum: 50}
	validates :cell_phone, length: {maximum: 25}, presence: true,
    format: { with: VALID_TELEPHONE_REGEX }
  validates :other_phone, length: {maximum: 25}, allow_blank: true,
    format: { with: VALID_TELEPHONE_REGEX }
	validates :email, presence: true, length: {maximum: 100},
						format: { with: VALID_EMAIL_REGEX }
            #uniqueness: { case_sensitive: false }
	validates :describe_pets, length: {maximum: 50}
	validates :num_roommates, presence: true, length: {maximum: 10}
	validates :relationship_to_roommates, length: {maximum: 100}
	validates :facebook_profile_url, length: {maximum: 100}
	validates :twitter_profile_url, length: {maximum: 100}
	validates :linkedin_profile_url, length: {maximum: 100}
	validates :bank_name, presence: true, length: {maximum: 100}
	validates :checking_acct_no, presence: true, length: {maximum: 50}
	validates :savings_acct_no, length: {maximum: 50}
	validates :relative_name, length: {maximum: 200}
	validates :relative_address, length: {maximum: 500}
	validates :relative_phone, length: {maximum: 20}
	validates :listing_address, presence: true, length: {maximum: 20}
	validates :listing_unit, presence: true, length: {maximum: 20}

	# current
	validates :curr_street_address, presence: true, length: {maximum: 100}
	validates :curr_apt_suite, allow_blank: true, length: {maximum: 50}
	validates :curr_city, presence: true, length: {maximum: 100}
	validates :curr_zip, presence: true, length: {maximum: 15}
	validates :curr_landlord_name, presence: true, length: {maximum: 50}
	validates :curr_daytime_phone, length: {maximum: 25}, presence: true,
    format: { with: VALID_TELEPHONE_REGEX }
    validates :curr_evening_phone, allow_blank: true, length: {maximum: 25},
    format: { with: VALID_TELEPHONE_REGEX }
	validates :curr_rent_paid, presence: true, length: {maximum: 50}
	validates :curr_tenancy_years, presence: true, length: {maximum: 10}
	validates :curr_tenancy_months, length: {maximum: 10}

	validates :curr_annual_income, presence: true, length: {maximum: 50}
	validates :curr_time_employed_years, presence: true, length: {maximum: 15}
	validates :curr_time_employed_months, length: {maximum: 15}
	validates :curr_dates_employed, presence: true, length: {maximum: 50}

	# previous
	validates :prev_street_address, allow_blank: true, length: {maximum: 100}
	validates :prev_apt_suite, allow_blank: true, length: {maximum: 50}
	validates :prev_city, allow_blank: true, length: {maximum: 100}
	validates :prev_zip, allow_blank: true, length: {maximum: 15}
	validates :prev_landlord_name, allow_blank: true, length: {maximum: 50}
	validates :prev_daytime_phone, allow_blank: true, length: {maximum: 25},
    format: { with: VALID_TELEPHONE_REGEX }
  validates :prev_evening_phone, allow_blank: true, length: {maximum: 25},
    format: { with: VALID_TELEPHONE_REGEX }

	validates :prev_rent_paid, allow_blank: true, length: {maximum: 50}
	validates :prev_tenancy_years, allow_blank: true, length: {maximum: 10}
	validates :prev_tenancy_months, allow_blank: true, length: {maximum: 10}

	validates :prev_annual_income, allow_blank: true, length: {maximum: 50}
	validates :prev_time_employed_years, allow_blank: true, length: {maximum: 15}
	validates :prev_time_employed_months, allow_blank: true, length: {maximum: 15}
	validates :prev_dates_employed, allow_blank: true, length: {maximum: 50}

	# terms
	validates_inclusion_of :is_sight_unseen, in: [true, false]
	validates_inclusion_of :allow_background_authorization, in: [true]
	validates_inclusion_of :received_disclosure, in: [true]
	validates_inclusion_of :accepts_terms, in: [true]

end