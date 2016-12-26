class Deal < ActiveRecord::Base
	scope :unarchived, ->{where(archived: false)}
	belongs_to :unit
  belongs_to :user
  has_many :clients

  enum state: [:accepted, :rejected, :dead]
  validates :state, presence: true, inclusion: {
    in: ['accepted', 'rejected', 'dead']
  }

  validates :unit_id, presence: true

  attr_accessor :building_id

	def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

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
    deals = Deal.unarchived
      .joins(unit: :building)
      .select('deals.id', 'deals.archived', 'deals.price', 'deals.closed_date', 'deals.commission',
        'deals.updated_at', 'deals.created_at', 'deals.state',
        'units.id as unit_id', 'units.building_unit',
        'buildings.street_number || \' \' || buildings.route as street_address2',
        'buildings.formatted_street_address')

    if !params[:address].blank?
      deals = deals.where("buildings.formatted_street_address ilike ?", "%#{params[:address]}%")
    end

    if !params[:landlord_code].blank?
      deals = deals.where("deals.landlord_code ilike ?", "%#{params[:landlord_code]}%")
    end

    if !params[:closed_date_start].blank?
      deals = deals.where("deals.closed_date > ?", params[:closed_date_start])
    end
    if !params[:closed_date_end].blank?
      deals = deals.where("deals.closed_date < ?", params[:closed_date_end])
    end

    if !params[:state].blank? && params[:state] != 'Any'
      deals = deals.where("deals.state = ?", Deal.states[params[:state].downcase])
    end

    deals
  end

  def self.search_csv(params)
    deals = Deal.unarchived
      .joins(unit: :building)
      .select('deals.*',
        'units.id as unit_id', 'units.building_unit',
        'buildings.street_number || \' \' || buildings.route as street_address2',
        'buildings.formatted_street_address')


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
