class Image < ActiveRecord::Base
	belongs_to :building, touch: true
	belongs_to :unit, touch: true
  default_scope { order("priority ASC") }
  after_save :check_priority

	# This method associates the attribute ":file" with a file attachment
  has_attached_file :file,
    styles: lambda { |a| {
      thumb: {
        geometry: '100x100>',
        rotation: a.instance.rotation,
        #processors: [:rotator]
      },
      # square: {
      #   geometry: '200x200#',
      #   rotation: a.instance.rotation,
      # },
      # medium: {
      #   geometry: '300x300>',
      #   rotation: a.instance.rotation,
      # },
      large: {
        geometry: '2500x2500>',
        rotation: a.instance.rotation,
        #processors: [:rotator]
      },
      original: {
        convert_options: '-auto-orient'
      }
    }},
    default_url: "/images/:style/listing_soon.png", #TODO: have a diff missing imag here
    convert_options: { all: '-auto-orient' },
    source_file_options: { all: '-auto-orient' }, processors: [:rotator]

    # styles: {
    #   original: {convert_options: '-auto-orient'},
    #   thumb:  '100x100>',
    #   square: '200x200#',
    #   medium: '300x300>',
    #   large:  '500x500>'
    # },

  process_in_background :file

  # Validate filename
  validates_attachment_file_name :file, :matches => [/png\Z/, /jpe?g\Z/, /gif\Z/, /PNG\Z/, /JPE?G\Z/, /GIF\Z/]

	# Validate the attached image content is image/jpg, image/png, etc
  validates_attachment :file,
		:presence => true,
		:content_type => { :content_type => /\Aimage\/.*\Z/ },
		:size => { :less_than => 4.megabyte }

  def to_builder
    Jbuilder.new do |i|
    end
  end

  def self.reorder_by_unit(unit_id)
    images = Image.where(unit_id: unit_id).order("priority ASC")
    pos = 0
    images.each{ |x|
      if x.priority != pos
        x.update_columns(priority: pos)
      end

      pos = pos + 1
    }
  end

  def self.reorder_by_building(bldg_id)
    images = Image.where(building_id: bldg_id).order("priority ASC")
    pos = 0
    images.each{ |x|
      if x.priority != pos
        x.update_columns(priority: pos)
      end
      pos = pos + 1
    }
  end

  # def rotate
  #   self.rotation += 90
  #   puts "**** NEW rotation is #{rotation}"
  #   self.rotation = self.rotation % 360 if (self.rotation >= 360 || self.rotation <= -360)
  #   self.update_attribute(:rotation, rotation)
  #   self.file.reprocess! :large
  # end

  private
    # preserve order. keep numbers starting at 0
    def check_priority
      images = []
      if self.building_id
        Image.reorder_by_building(building_id)
      elsif self.unit_id
        Image.reorder_by_unit(unit_id)
      end
    end
end