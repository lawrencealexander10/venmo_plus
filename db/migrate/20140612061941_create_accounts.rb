class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :user_id
      t.float :remaining_borrow
      t.float :lending_funds
      t.float :collateral
      t.float :balance

      t.timestamps
    end
  end
end
