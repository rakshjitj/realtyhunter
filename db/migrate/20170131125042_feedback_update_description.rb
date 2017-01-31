class FeedbackUpdateDescription < ActiveRecord::Migration
  def change
    change_column_default :feedbacks, :description, nil
  end
end
