#
# Encapsulates data from Wufoo form
#
class WufooPartnerForm < ActiveRecord::Base
	belongs_to :company, touch: true

  scope :unarchived, ->{where(archived: false)}

  validates :name, presence: true, length: {maximum: 200}
  validates :email, presence: true, length: {maximum: 100}
  validates :phone_number, presence: true, length: {maximum: 20}
  validates :how_did_you_hear_about_us, presence: true, length: {maximum: 1000}
  validates :address_street_address, allow_blank: true, length: {maximum: 500}
  validates :address_address_line_2, allow_blank: true, length: {maximum: 500}
  validates :address_city, allow_blank: true, length: {maximum: 500}
  validates :address_state_province_region, allow_blank: true, length: {maximum: 100}
  validates :address_postal_zip_code, allow_blank: true, length: {maximum: 15}
  validates :address_country, allow_blank: true, length: {maximum: 500}
  validates :number_of_bedrooms, allow_blank: true, length: {maximum: 10}
  validates :renovated, allow_blank: true, length: {maximum: 1000}

  def archive
    self.archived = true
    self.save
  end

  def unarchive
    self.archived = false
    self.save
  end

  def self.find_unarchived(id)
    WufooPartnerForm.where(id: id).where(archived:false).first
  end

  def self.send_message(source_agent, recipients, sub, msg)
    if source_agent
      WufooFormsMailer.send_message(source_agent, recipients, sub, msg).deliver_now
    else
      "No sender specified"
    end
  end

  def mark_read
    if !read
      self.update!(read: true)
      puts "UPDATED #{self.inspect}"
    end
  end

  def self.mark_read(ids)
    entries = WufooPartnerForm.where(id: ids)
    entries.each{ |e| e.mark_read }
  end

  def full_address
    ret = address_street_address
    if !address_address_line_2.blank?
      ret = ret + ", " + address_address_line_2
    end
    ret = ret + "," + address_city + ", " + address_state_province_region + " " +
      address_postal_zip_code + " " + address_country
    ret
  end

  def utilities
    ret = []
    if utilities_heat_included
      ret << "Heat Included"
    end

    if utilities_hot_water_included
      ret << "Hot Water Included"
    end

    if utilities_gas_included
      ret << "Gas Included"
    end

    if utilities_electric_included
      ret << "Electric Included"
    end

    if utilities_no_utilities_included
      ret << "No Utilities Included"
    end

    ret.join(", ")
  end

  def self.search(params)
    entries = WufooPartnerForm.all

     # all search params come in as strings from the url
    # clear out any invalid search params
    params.delete_if{ |k,v| (!v || v == 0 || v.empty?) }

    if !params[:ids].blank?
      entries = entries.where(id: params[:ids])
    end

    if !params[:name].blank?
      entries = entries.where("name ilike ?", "%#{params[:name]}%")
    end

    if !params[:address_street_address].blank?
      entries = entries.where("address_street_address ilike ?", "%#{params[:address_street_address]}%")
    end

    if !params[:number_of_bedrooms].blank?
      entries = entries.where(number_of_bedrooms: params[:number_of_bedrooms])
    end

    if !params[:renovated].blank?
      entries = entries.where(renovated: params[:renovated])
    end

    if !params[:move_in_date].blank?
      entries = entries.where('move_in_date >= ?', params[:move_in_date])
    end

    if !params[:status].blank?
      status = (params[:status] == 'Active') ? false : true
      entries = entries.where('archived = ?', status)
    end

    if !params[:submitted_date].blank?
      entries = entries.where('created_at >= ?', params[:submitted_date])
    end

    entries
  end

end
