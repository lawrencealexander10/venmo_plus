class AddAccountIdToTransfers < ActiveRecord::Migration
def change
  	add_column :transfers, :account_id, :integer
  end
end
