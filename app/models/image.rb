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
        rotation: a.instance.rotation
      },
      large: {
        geometry: '2500x2500>',
        rotation: a.instance.rotation,
        watermark_path: "#{Rails.root}/public/watermark-logo.png"
      },
      original: {
        convert_options: '-auto-orient',
        watermark_path: "#{Rails.root}/public/watermark-logo.png"
      }
    }},
    #default_url: Rails.root + "/images/:style/missing.png",
    only_process: [:thumb, :large], #, :original
    convert_options: { all: '-auto-orient' },
    source_file_options: { all: '-auto-orient' },
    # processors: [:rotator, :watermark]
    processors: lambda { |p|
      p.apply_processors
    }

  # process_in_background :file, processing_image_url: :processing_image_fallback,
  #   only_process: [:large, :original]
    #processing_image_url: Rails.root + "/images/:style/image_uploading.jpg",

  def apply_processors
    if self.user_id.present? or self.company_id.present?
      [:compression]
    else
      [:watermark, :compression]
    end
  end

  def processing_image_fallback
    options = file.options
    options[:interpolator].interpolate(options[:url], file, :original)
  end

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
