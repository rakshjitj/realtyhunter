class OpenHouse < ApplicationRecord
  belongs_to :unit, touch: true

  validates_date :day, allow_blank: false,
      before: lambda { 1.year.from_now },
      before_message: 'must not be more than a year from today',
      invalid_date_message: 'must be formatted correctly'

  validates_time :start_time, allow_blank: false
  validates_time :end_time, allow_blank: false,
      after: :start_time,
      after_message: 'must be after start time'
end
