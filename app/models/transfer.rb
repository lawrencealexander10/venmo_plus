class Transfer < ActiveRecord::Base
	belongs_to :account
	has_many :transactions, :dependent => :destroy
validates :message, presence: true
validates :amount, presence: true



	# has_one :user, through: :account
	#does anything go here in respect to user 
	def self.create_transfer(transfer_params, user)
		transfer = Transfer.new(transfer_params)
		total = 0 
		total_borrow_amount = transfer_params[:amount].to_f
		remaining_borrow = user.account.remaining_borrow
		#set variable n=5
		n = 5
		
		@users = User.all_except(user)
		@users.each do |i|
			total += i.account.lending_funds
		end
		# if transfer_params :amount > all lenders lending_amount then can't issue transfers
		if total < total_borrow_amount
			return [false, "Your investors lack the funds. We are working to address this issue in the future!"]
		# if transfer_params :amount > remaining_borrow then can't issue transfers
		elsif total_borrow_amount > remaining_borrow
			return [false, "Not enough money"]
		elsif total_borrow_amount<0
			return [false, "You cant borrow negative money"]
		elsif User.all_except(user)
			return [false, "You don't have any friends"]
		end

		#Sort all users excluding self by lending amount


		funds = Account.where("user_id != ?", user.id).pluck(:user_id, :lending_funds).to_h
		sorted_funds = funds.sort_by{|u,l| l}.reverse
		
		if total_borrow_amount < 200
		#look at top 5 users
		sorted_funds = sorted_funds.first(n).to_h
		borrow_check = sorted_funds.first(n).map(&:second)
		# find the total amount of lending funds from top 5 lenders
		local_total = borrow_check.inject(:+)
				# if lending funds from top 5 friends is less then amount then
			while local_total < total_borrow_amount
				# add 1 user onto number of lenders
				n +=1
				borrow_check = sorted_funds.first(n).map(&:second)
				# sum up the amount of lending funds with new lender(s)
				local_total = borrow_check.inject(:+)
			end
				# divide total borrowing amount by number of lenders
			per_lender_amount = total_borrow_amount/(borrow_check.length)
			left_over = 0
			individual_loan_amount = []
			# for each lender 
			(borrow_check.length-1).downto(0) do |i|
				excess = per_lender_amount + left_over
				# if the individual lender funds is less than the individual lending amount + the left over amount from the previous lender
				if borrow_check[i] < excess
					# take all their lending funds
					individual_loan_amount[i] = borrow_check[i] 
					# subtract the individual lender's amount from the amount the person was suppose to give
					left_over = per_lender_amount - borrow_check[i]
				else 
					# if the user can affored to pay the individual amount and any extra amount from the previous user
					individual_loan_amount[i] = excess
					# reset the left over
					left_over = 0
				end
			end
			# subtract the amount each lender is giving from their lending funds
			individual_loan_amount.each_index do |i|
				sorted_funds[sorted_funds.keys[i]] = individual_loan_amount[i]
			end
		else 
			# if amount > 200
			# sort accounts 
			# take lending funds as array
		n=1
		sorted_funds = sorted_funds.to_h
		borrow_check = sorted_funds.first(n).map(&:second)
		local_total = 0
		local_total = borrow_check.inject(:+)
		while local_total < total_borrow_amount
			# if lending funds from bottom n friends is less then amount then
			# add 1 user onto number of lenders
			n +=1
			borrow_check = sorted_funds.first(n).map(&:second)
			# sum up the amount of lending funds with new lender(s)
			local_total = borrow_check.inject(:+)
		end
			# if total lending funds > total amount
			# subtract total lending funds from total amount
			# give that extra money back to the last user 
			borrow_check[-1] = (local_total - total_borrow_amount)

			borrow_check.each_index do |i|
				sorted_funds[sorted_funds.keys[i]] = borrow_check[i]
			
			end
			
		end
		if transfer.save
			expiration_date= transfer.created_at+30.days
			transfer.update_attributes(account_id: user.account.id, :completed => false, :expiration_date => expiration_date)
		#creating a transaction for every lender borrow and deducting from their account
			sorted_funds.each do |key, value|
				transaction= Transaction.create!(:transfer_id => transfer.id, :lender_id => key,  :lend_amount => value)
				transaction.borrow

			end
			#add money to my balance
			my_new_balance= user.account.balance + transfer.amount
			user.account.update_attributes(:balance => my_new_balance)

			#subtract money from remaining borrow
			my_new_remaining_borrow= user.account.remaining_borrow - transfer.amount
			user.account.update_attributes(:remaining_borrow => my_new_remaining_borrow)

			return [transfer, "You just borrowed $#{transfer.amount}"]
		end
	end

	# def self.update_transfer(update_params, user)
		
	# end	 
	def self.update_transfer(update_params, user)
		#use current transfer 
		total_payment_amount= update_params[:amount].to_f
		current_transfer= 

		if total_payment_amount<0
			return [false, "Not a valid amount"]
		elsif total_payment_amount>current_transaction.amount
			return [false, "Payment is too much"]
		end


		current_lenders= current_transfer.transaction.all
		current_lenders.pluck(:lender_id, :lend_amount).to_h

		sorted_funds = funds.sort_by{|u,l| l}.reverse
		sorted_funds = sorted_funds.to_h
		n=1
		payment_check = sorted_funds.first(n).map(&:second)

		local_total = 0
		local_total = payment_check.inject(:+)
		while local_total < total_payment_amount
			# if lending funds from bottom n friends is less then amount then
			# add 1 user onto number of lenders
			n +=1
			borrow_check = sorted_funds.first(n).map(&:second)
			# sum up the amount of lending funds with new lender(s)
			local_total = borrow_check.inject(:+)
		end
			# if total lending funds > total amount
			# subtract total lending funds from total amount
			# give that extra money back to the last user 
			borrow_check[-1] = (local_total - total_payment_amount)

			borrow_check.each_index do |i|
				sorted_funds[sorted_funds.keys[i]] = borrow_check[i]
			
			end
			sorted_funds.each do |key, value|
				transaction= current_transfer.transaction.where(id: key)
				new_transaction_amount = transaction.amount- value
				transaction.update_attributes(amount: new_transaction_amount)
				transaction.payment(value)

			end


			new_amount= current_transfer.amount- total_payment_amount
			current_transfer.update_attributes(amount: new_amount)
			user.account.remaining_borrow += total_payment_amount
	end

end
