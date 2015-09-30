class ImageSerializer < ActiveModel::Serializer
	#include NullAttributesRemover
  attributes :original, :thumbnail

  def original
  	object ? object.file.url(:large) : "test" #:original
  end

  def thumbnail
  	object ? object.file.url(:thumb) : nil
  end
end