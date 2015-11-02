# 
# Encapsulates data from Wufoo form
#
class WufooCareerForm < ActiveRecord::Base
	belongs_to :company, touch: true
	
  scope :unarchived, ->{where(archived: false)}

  validates :name, presence: true, length: {maximum: 200}
  validates :phone_number, presence: true, length: {maximum: 20}
  validates :email, presence: true, length: {maximum: 100}
  validates :what_neighborhood_do_you_live_in, allow_blank: true, length: {maximum: 1000}
 
  def archive
    self.archived = true
    self.save
  end
  
  def unarchive
    self.archived = false
    self.save
  end

  def self.find_unarchived(id)
    WufooCareerForm.where(id: id).where(archived:false).first
  end 

  def self.send_message(source_agent, recipients, sub, msg)
    if source_agent
      WufooFormsMailer.send_message(source_agent, recipients, sub, msg).deliver_now
    else
      "No sender specified"
    end
  end
  
  def self.search(params)
    entries = WufooCareerForm.all

     # all search params come in as strings from the url
    # clear out any invalid search params
    params.delete_if{ |k,v| (!v || v == 0 || v.empty?) }

    if !params[:ids].blank?
      entries = entries.where(id: params[:ids])
    end

    if !params[:name].blank?
      entries = entries.where(name: params[:name])
    end

    if !params[:email].blank?
      entries = entries.where(email: params[:email])
    end

    if !params[:status].blank? && params[:status] != 'Any'
      puts "******* STATUS #{params[:status]}"
      archived = (params[:status] == 'Active') ? false : true
      entries = entries.where('archived = ?', archived)
    end

    if !params[:submitted_date].blank?
      entries = entries.where('created_at >= ?', params[:submitted_date])
    end
    
    entries
  end

end
