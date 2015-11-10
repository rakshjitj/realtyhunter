class Deal < ActiveRecord::Base
	scope :unarchived, ->{where(archived: false)}
	default_scope { order("updated_at DESC") }
	belongs_to :unit
  belongs_to :user
  has_many :clients

  #validates :price, presence: true
  validates :unit_id, presence: true

	def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

  def self._search(params)
    deals = Deal.unarchived

    #if params[]
    #end
  end

  def self.search(params)
    deals = Deal._search(params)
    #deals = deals.select('')
    deals
  end

  def self.search_csv(params)
    deals = Deal._search(params)
    deals
  end

end