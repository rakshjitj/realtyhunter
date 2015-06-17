class Image < ActiveRecord::Base
	belongs_to :building
	# attachment :file, type: :image

	# after_destroy :remove_file

	# private

 #    def remove_file
 #      file.delete
 #    end
    
end