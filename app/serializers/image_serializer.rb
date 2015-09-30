class ImageSerializer < ActiveModel::Serializer
	#include NullAttributesRemover
  attributes :original, :thumbnail

  def original
  	if object
  		if object.file.exists?(:large)
  			object.file.url(:large)
			else
				object.file.url(:medium)
			end
  	else
  		"test"
  	end
  	#object ? object.file.url(:large) : "test" #:original
  end

  def thumbnail
  	object ? object.file.url(:thumb) : nil
  end
end