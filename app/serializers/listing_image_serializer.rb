class ListingImageSerializer < ActiveModel::Serializer
	attributes :large, :is_floorplan, :small, :media_type, :original, :id, :thumbnail

	def large
		object.file.url(:medium)
  end

  def is_floorplan
  	false
  end

  def local_file_name
  	object.file_file_name
  end
  
  def small
  	object.file.url(:square)
  end

  def media_type
  	"10"
  end

  def original
  	#object.file.url(:large)#:original)
    if image.file.exists?(:large)
      object.file.url(:large)
    else
      object.file.url(:medium)
    end
  end

  def id
  	nil
  end

  def thumbnail
  	object.file.url(:thumb)
  end

end