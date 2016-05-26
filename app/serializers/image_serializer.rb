class ImageSerializer < ActiveModel::Serializer
  attributes :original, :thumbnail

  def original
  	object ? object.file.url(:large) : nil
  end

  def thumbnail
  	object ? object.file.url(:thumb) : nil
  end
end
