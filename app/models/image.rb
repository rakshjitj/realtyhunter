class Image < ActiveRecord::Base
	belongs_to :building
	belongs_to :unit
  default_scope { order("priority ASC") }
  
	# This method associates the attribute ":file" with a file attachment
  has_attached_file :file, styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '300x300>'
  }

  # Validate filename
  validates_attachment_file_name :file, :matches => [/png\Z/, /jpe?g\Z/, /gif\Z/, /PNG\Z/, /JPE?G\Z/, /GIF\Z/]

	# Validate the attached image content is image/jpg, image/png, etc
  validates_attachment :file,
		:presence => true,
		:content_type => { :content_type => /\Aimage\/.*\Z/ },
		:size => { :less_than => 4.megabyte }

end