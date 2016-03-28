class OpenHouse < ActiveRecord::Base
  belongs_to :unit, touch: true
end
