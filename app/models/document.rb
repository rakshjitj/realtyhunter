class Document < ActiveRecord::Base
	belongs_to :building, touch: true
	belongs_to :unit, touch: true
  default_scope { order("priority ASC") }
  after_save :check_priority

	# This method associates the attribute ":file" with a file attachment
  has_attached_file :file, styles: {
      original: {convert_options: '-auto-orient'},
      #thumb:  '100x100>',
      #square: '200x200#',
      #large:  '500x500>'
    }, 
    convert_options: { :all => '-auto-orient' }, 
    source_file_options: { :all => '-auto-orient' }
    #default_url: "/documents/:style/missing.png"
  process_in_background :file

  # Validate filename
  validates_attachment_file_name :file, :matches => [
    /pdf\Z/, /doc\Z/, /xls\Z/, /xlsx\Z/, 
    /PDF\Z/, /DOC\Z/, /XLS\Z/, /XLSX\Z/]

	# Validate the attached document content is image/jpg, image/png, etc
  validates_attachment :file,
		:presence => true,
		#:content_type => { :content_type => /\Aimage\/.*\Z/ },
		:size => { :less_than => 4.megabyte }

  def to_builder
    Jbuilder.new do |i|
    end
  end

  def self.reorder_by_unit(unit_id)
    documents = Document.where(unit_id: unit_id).order("priority ASC")
    pos = 0
    documents.each{ |x|
      if x.priority != pos
        x.update_columns(priority: pos)
      end
      pos = pos + 1
    }
  end

  def self.reorder_by_building(bldg_id)
    documents = Document.where(building_id: bldg_id).order("priority ASC")
    pos = 0
    documents.each{ |x|
      if x.priority != pos
        x.update_columns(priority: pos)
      end
      pos = pos + 1
    }
  end

  private

    # preserve order. keep numbers starting at 0
    def check_priority
      documents = []
      if self.building_id
        Document.reorder_by_building(building_id)
      elsif self.unit_id
        Document.reorder_by_unit(unit_id)
      end
    end
end