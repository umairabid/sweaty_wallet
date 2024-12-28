class CreateFileImport < ActiveRecord::Migration[7.1]
  def change
    create_table :file_imports do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :status, null: false, default: 1
      t.jsonb :input, default: {}
      t.jsonb :output, default: {}

      t.timestamps
    end
  end
end
