class Transaction < ActiveRecord::Base
	belongs_to :transfer

	def borrow
		account= Account.find_by(user_id: self.lender_id)
		new_amount= account.lending_funds - self.lend_amount
		account.update_attributes(:lending_funds => new_amount)
	end

end
