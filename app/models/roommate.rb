#
# Data pulled from Wufoo form or roommate referral form on RealtyHunter.
#
#
class Roommate < ActiveRecord::Base
	belongs_to :user, touch: true
	belongs_to :neighborhood, touch: true
	has_one :image, dependent: :destroy
	
	default_scope { order("roommates.created_at ASC") }
	scope :unarchived, ->{where(archived: false)}
	
	validates :name_first, presence: true, length: {maximum: 50}
	validates :name_last, presence: true, length: {maximum: 50}
	validates :phone_number, presence: true, length: {maximum: 20}
	validates :email, length: {maximum: 100}
	validates :how_did_you_hear_about_us, presence: true, length: {maximum: 1000}
	validates :describe_yourself, allow_blank: true, length: {maximum: 1000}
	validates :upload_picture_of_yourself, length: {maximum: 500}
	validates :monthly_budget, length: {maximum: 50}
	validates :move_in_date, length: {maximum: 50}
	#validates :what_neighborhood_do_you_want_to_live_in, length: {maximum: 100}
	#validates :neighborhood
	validates :dogs_allowed, length: {maximum: 50}
	validates :cats_allowed, length: {maximum: 50}

	def archive
    self.unit.archived = true
    self.unit.save
  end
  
  def self.find_unarchived(id)
    Roommate.where(id: id).where(archived:false).first
  end

	def self.search(params)
		Roommate.unarchived.joins('left join neighborhoods on roommates.neighborhood_id = neighborhoods.id').select(
			'roommates.id',
			'upload_picture_of_yourself',
			'name_first', 'name_last', 'phone_number', 'email', 
			'neighborhoods.name as neighborhood_name',
			'monthly_budget', 'move_in_date', 'dogs_allowed', 'cats_allowed',
			'roommates.created_at as submitted_date',
			'roommates.archived'
			)
	end

	def self.get_images(list)
    ids = list.map(&:id)
    Image.where(roommate_id: ids).index_by(&:roommate_id)
  end

	def name
		name_first + ' ' + name_last
	end

end