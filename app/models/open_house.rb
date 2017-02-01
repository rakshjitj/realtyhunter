class OpenHouse < ActiveRecord::Base
  belongs_to :unit, touch: true

  validates_date :day, allow_blank: false,
      on_or_after: lambda { Date.current },
      on_or_after_message: 'Open house date can not be in the past',
      before: lambda { 1.year.from_now },
      before_message: 'must not be more than a year from today',
      invalid_date_message: 'must be formatted correctly'

  validates_time :start_time, allow_blank: false
  validates_time :end_time, allow_blank: false,
      after: :start_time,
      after_message: 'must be after start time'
end
