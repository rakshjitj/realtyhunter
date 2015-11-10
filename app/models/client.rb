class Client < ActiveRecord::Base
	scope :unarchived, ->{where(archived: false)}
	belongs_to :deal

	#validates :name, presence: true
	#validates :email, presence: true
	#validates :phone, presence: true
	#validates :date_of_birth, presence: true

	def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

end