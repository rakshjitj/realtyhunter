class AddFeedbackCategoryAndPhotoErrorTypeInFeedbacks < ActiveRecord::Migration[5.0]
  def change
  	add_column :feedbacks, :feedback_category, :string
  	add_column :feedbacks, :photo_error_type, :string
  end
end
