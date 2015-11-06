# 
# Encapsulates data from Wufoo form
#
class WufooListingsForm < ActiveRecord::Base
	belongs_to :company, touch: true
	
  scope :unarchived,  ->{where(archived: false)}
  scope :residential, ->{where(is_residential: true)}
  scope :commercial,  ->{where(is_commercial: true)}

  validates :name, presence: true, length: {maximum: 200}
  validates :email, presence: true, length: {maximum: 100}
  validates :phone_number, presence: true, length: {maximum: 20}
  validates :message, presence: true, length: {maximum: 1000}
  
  def archive
    self.archived = true
    self.save
  end
  
  def unarchive
    self.archived = false
    self.save
  end

  def self.find_unarchived(id)
    WufooListingsForm.where(id: id).where(archived:false).first
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
      self.update_attribute(:read, true)
    end
  end

  def self.mark_read(ids)
    entries = WufooCareerForm.where(id: ids)
    entries.each{ |e| e.mark_read }
  end
  
  def self.search(params)
    entries = WufooListingsForm.all

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
