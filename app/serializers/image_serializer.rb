class ImageSerializer < ActiveModel::Serializer
	#include NullAttributesRemover
  attributes :original, :thumbnail

  def original
  	object ? object.file.url(:original) : "test"
  end

  def thumbnail
  	object ? object.file.url(:thumb) : nil
  end
end