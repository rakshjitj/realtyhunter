class AddFeedbackTable < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.belongs_to :unit, index: true
      t.belongs_to :building, index: true
      t.belongs_to :user, index: true
      t.text :description
      t.boolean :price_drop_request, default: false
      t.timestamps null: false
    end

    add_reference :units, :feedback, index: true
    add_reference :buildings, :feedback, index: true
    add_reference :users, :feedback, index: true
  end
end
