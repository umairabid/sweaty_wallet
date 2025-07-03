class AddSuggestedCategoryInTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :transactions, :suggested_category, foreign_key: { to_table: :categories }
  end
end
