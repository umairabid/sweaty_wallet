class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.integer :parent_category_id, index: true
      t.string :name, null: false
      t.string :code, null: false
      t.references :user, foreign_key: true, index: true, null: false
      t.timestamps
    end
  end
end
