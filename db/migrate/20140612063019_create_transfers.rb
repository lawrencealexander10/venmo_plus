class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.float :amount
      t.text :message
      t.datetime :expiration_date
      t.boolean :completed

      t.timestamps
    end
  end
end
