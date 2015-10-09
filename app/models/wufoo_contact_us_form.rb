# 
# Encapsulates data from Wufoo form
#
class WufooContactUsForm < ActiveRecord::Base
	belongs_to :company, touch: true
	
  scope :unarchived, ->{where(archived: false)}

  validates :name, presence: true, length: {maximum: 200}
  validates :email, presence: true, length: {maximum: 100}
  validates :phone_number, presence: true, length: {maximum: 20}
  validates :how_did_you_hear_about_us, length: {maximum: 1000}
  validates :min_price, length: {maximum: 20}
  validates :max_price, length: {maximum: 20}
  validates :any_notes_for_us, allow_blank: true, length: {maximum: 1000}
 
  def archive
    self.archived = true
    self.save
  end
  
  def unarchive
    self.archived = false
    self.save
  end

  def self.find_unarchived(id)
    WufooContactUsForm.where(id: id).where(archived:false).first
  end 

  def self.send_message(source_agent, recipients, sub, msg)
    if source_agent
      WufooFormsMailer.send_message(source_agent, recipients, sub, msg).deliver_now
    else
      "No sender specified"
    end
  end
  
end
