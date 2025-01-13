class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents do |t|
      t.string :name
      t.string :file_path
      t.references :folder, null: false, foreign_key: true

      t.timestamps
    end
  end
end
