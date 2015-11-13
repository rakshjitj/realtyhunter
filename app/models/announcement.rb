class Announcement < ActiveRecord::Base
	default_scope { order("updated_at DESC") }
	belongs_to :user

  enum category: [:residential, :commercial, :sales, :event]
  validates :category, presence: true, inclusion:
    { in: ['residential', 'commercial', 'sales', 'event'] }

	validates :note, allow_blank: true, length: {maximum: 140}

  def self.search(params)
    entries = Announcement.joins(:user)
      .select('announcements.id', 'announcements.updated_at', 'announcements.category',
        'announcements.note', 'users.name AS sender_name')
      .limit(params[:limit]).uniq

    if !params[:created_start].blank?
      entries = entries.where('announcements.created_at > ?', params[:created_start]);
    end

    if !params[:created_end].blank?
      entries = entries.where('announcements.created_at < ?', params[:created_end]);
    end

    if !params[:category_filter].blank?
      entries = entries.where('announcements.category = ?', Announcement.categories[params[:category_filter].downcase]);
    end

    entries
  end

	def broadcast(current_user)
		# NOTE: We've decided to go with email instead of texting for now, to save on costs.
		#client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
		recipients = ['myspaceupdates@myspacenyc.com']
	  AnnouncementMailer.send_broadcast(
      current_user, recipients, note).deliver_now
	  self.update_attribute(:was_broadcast, true)
	end

end
