# frozen_string_literal: true

class CreateConnectors < ActiveRecord::Migration[7.1]
  def change
    create_table :connectors do |t|
      t.integer :bank, null: false, index: true
      t.integer :auth_type, null: false, index: true
      t.string :username
      t.string :password
      t.references :user
      t.timestamps
    end
  end
end
