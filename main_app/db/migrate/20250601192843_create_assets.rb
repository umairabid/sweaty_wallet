class CreateAssets < ActiveRecord::Migration[7.1]
  def change
    create_table :assets do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.string :name, null: false
      t.integer :asset_type, null: false, default: 0
      t.decimal :value, null: false
      t.text :description
      t.timestamps
    end
  end
end
