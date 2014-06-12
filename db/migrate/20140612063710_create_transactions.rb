class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :lender_id
      t.float :lend_amount
      t.integer :transfer_id

      t.timestamps
    end
  end
end
