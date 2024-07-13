class AddSecondaryExternalIdAndExternalObjectToTransactions < ActiveRecord::Migration[7.1]
  def change
    change_table(:transactions) do |t|
      t.string :secondary_external_id, index: true, null: true, default: nil
      t.jsonb :external_object, default: {}
    end
  end
end
