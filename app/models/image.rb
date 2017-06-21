class Image < ApplicationRecord
  audited
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
        no_watermark: true,
      },
      large: {
        geometry: '2500x2500>',
        rotation: a.instance.rotation,
        watermark_path: "#{Rails.root}/public/watermark-logo-sm.png"
      },
      large_unmarked: { # no watermarks applied
        geometry: '2500x2500>',
        rotation: a.instance.rotation,
        no_watermark: true,
      },
      original: {
        convert_options: '-auto-orient',
        no_watermark: true,
      }
    }},
    #default_url: Rails.root + "/images/:style/missing.png",
    # disabled becauses we want to process everything upfront:
    # only_process: [:thumb, :large, :large_unmarked], #:thumb, :large,
    convert_options: { all: '-auto-orient' },
    source_file_options: { all: '-auto-orient' },
    # processors: [:rotator, :watermark]
    processors: lambda { |instance|
      instance.apply_processors
    }

  # NOTE: We need access to all our images immediately, so don't process in the background
  # process_in_background :file, #processing_image_url: :processing_image_fallback,
  #   only_process: [:large, :original]
  #   #processing_image_url: Rails.root + "/images/:style/image_uploading.jpg",

  def apply_processors
    if user_id.present? or company_id.present? or file.options[:no_watermark]
      [:compression]
    else
      [:watermark, :compression]
    end
  end

  # def processing_image_fallback
  #   options = file.options
  #   options[:interpolator].interpolate(options[:url], file, :original)
  # end

  # Validate filename
  validates_attachment_file_name :file,
      :matches => [/png\Z/, /jpe?g\Z/, /gif\Z/, /PNG\Z/, /JPE?G\Z/, /GIF\Z/]

	# Validate the attached image content is image/jpg, image/png, etc
  validates_attachment :file,
		:presence => true,
		:content_type => { :content_type => /\Aimage\/.*\Z/ },
		:size => { :less_than => 4.megabyte }

  validate :file_dimensions

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

    def file_dimensions
      if !self.user_id && file.queued_for_write[:original]
        dimensions = Paperclip::Geometry.from_file(file.queued_for_write[:original].path)
        # unless dimensions.width >= width && dimensions.height >= height
        #   errors.add :file, "Width must be #{width}px and height must be #{height}px"
        # end
        min_width = 1024
        min_height = 768
        max_width = 1350
        max_height = 900
        error_msg = "Image dimensions must be between #{min_width}x#{min_height} and #{max_width}x#{max_height} px"
        unless dimensions.width >= min_width && dimensions.width <= max_width &&
          dimensions.height = min_height && dimensions.height <= max_height
            errors.add :file, error_msg
        end
      end
    end

end
