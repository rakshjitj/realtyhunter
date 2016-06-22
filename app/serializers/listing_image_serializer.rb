class ListingImageSerializer < ActiveModel::Serializer
	attributes :large, :is_floorplan, :media_type, :original, :id, :thumbnail

	def large
		object.file.url(:large)
  end

  def is_floorplan
  	false
  end

  def local_file_name
  	object.file_file_name
  end

  def media_type
  	"10"
  end

  # Never ever return the original image, because it has not been processed
  # We've kept the "original" accessor here to maintain compatibility with BlankSlate's existing
  # use of Nestio's API (which we've since transitioned off of).
  def original
  	object.file.url(:large)
  end

  # todo: not used. remove!
  def id
  	nil
  end

  def thumbnail
  	object.file.url(:thumb)
  end

end
