class Feedback < ActiveRecord::Base
  default_scope { order("updated_at DESC") }
  belongs_to :user
  belongs_to :unit
  belongs_to :building

  validates :description, allow_blank: true, length: {maximum: 2000}
end
