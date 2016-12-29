class Checkin < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :unit, touch: true
end
