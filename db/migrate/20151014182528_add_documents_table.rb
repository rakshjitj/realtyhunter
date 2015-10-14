class AddDocumentsTable < ActiveRecord::Migration
  def change

  	# uses paperclip to upload to S3
    create_table :documents do |t|
      t.attachment :file
      t.boolean :file_processing
      t.integer :priority
      t.belongs_to :building
      t.belongs_to :unit
    end

    add_reference :units, :documents, index: true
    add_reference :buildings, :documents, index: true
  end
end
