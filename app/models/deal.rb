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

  # used as a sorting condition
  def street_address_and_unit
    output = ""
     # calling from 'show', for example with full objects loaded
    if !self.respond_to? :street_number
      if unit.building.street_number
        output = unit.building.street_number + ' ' + unit.building.route
      end

      if unit.building_unit && !unit.building_unit.empty?
        output = output + ' #' + unit.building_unit
      end
    else # otherwise, we used a select statement to cherry pick fields
      if street_number
        output = street_number + ' ' + route
      end

      if !building_unit.blank?
        output = output + ' #' + building_unit
      end
    end

    output
  end

  def self.search(params)
    puts params
    puts params[:closed_date_end]
    deals = Deal.unarchived
      .joins(unit: :building)
      .select('deals.id', 'deals.archived', 'deals.price', 'deals.closed_date', 'deals.commission', 
        'deals.updated_at', 'deals.created_at',
        'units.id as unit_id', 'units.building_unit',
        'buildings.street_number', 'buildings.route', 'buildings.formatted_street_address')

    if !params[:address].blank?
      deals = deals.where("buildings.formatted_street_address ilike ?", params[:address])
    end

    if !params[:closed_date_start].blank?
      deals = deals.where("deals.closed_date > ?", params[:closed_date_start]);
    end
    if !params[:closed_date_end].blank?
      deals = deals.where("deals.closed_date < ?", params[:closed_date_end]);
    end

    deals
  end

  def self.search_csv(params)
    deals = Deal.unarchived
      .joins(unit: :building)

    if !params[:address].blank?
      deals = deals.where("buildings.formatted_street_address ilike ?", params[:address])
    end

    if !params[:closed_date_start].blank?
      deals = deals.where('deals.closed_date > ?', params[:closed_date_start]);
    end
    if !params[:closed_date_end].blank?
      deals = deals.where('deals.closed_date < ?', params[:closed_date_end]);
    end

    deals
  end

end