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
		total_borrow_amount = transfer_params[:amount].to_f.round(2)
		remaining_borrow = user.account.remaining_borrow
		#set variable n=5
		n = 5
		
		@users = User.all_except(user)
		@users.each do |i|
			total += i.account.lending_funds
		end
		# if transfer_params :amount > all lenders lending_amount then can't issue transfers
		if !User.all_except(user)
			return [false, "You don't have any friends"]
		# if transfer_params :amount > remaining_borrow then can't issue transfers
		elsif total_borrow_amount > remaining_borrow
			return [false, "Not enough money"]
		elsif total_borrow_amount<0
			return [false, "You cant borrow negative money"]
		elsif total < total_borrow_amount
			return [false, "Your investors lack the funds. We are working to address this issue in the future!"]
		end


		#Sort all users excluding self by lending amount


		funds = Account.where("user_id != ?", user.id).pluck(:user_id, :lending_funds)
		funds = funds.to_h

		
		
		if total_borrow_amount < 200
		#look at top 5 users
		sorted_funds = funds.sort_by{|u,l| l}.reverse

		
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
			borrow_check -=[0.0]

				# divide total borrowing amount by number of lenders
			per_lender_amount = total_borrow_amount/(borrow_check.length)
			per_lender_amount = per_lender_amount.round(2)
			rounding_error = (total_borrow_amount - (per_lender_amount*(borrow_check.length))).round(2)

		

			left_over = 0
			individual_loan_amount = []
			# for each lender 
			(borrow_check.length-1).downto(0) do |i|
				excess = (per_lender_amount + left_over + rounding_error).round(2)
				rounding_error = 0
				
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

			individual_loan_amount -= [0.0]


			sorted_funds2 = sorted_funds.first(individual_loan_amount.length).to_h
			# subtract the amount each lender is giving from their lending funds
			individual_loan_amount.each_index do |i|
				sorted_funds2[sorted_funds2.keys[i]] = individual_loan_amount[i]
			end


		else 
			# if amount > 200
			# sort accounts 
			# take lending funds as array
		sorted_funds = funds.sort_by{|u,l| l}
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
			sorted_funds2 = sorted_funds.first(n).to_h
			borrow_check.each_index do |i|
				sorted_funds2[sorted_funds2.keys[i]] = borrow_check[i]
			
			end
			
		end
		if transfer.save

			expiration_date= transfer.created_at+30.days
			transfer.update_attributes(account_id: user.account.id, :completed => false, :expiration_date => expiration_date)


			transfer.update_attributes(account_id: user.account.id)

		#creating a transaction for every lender borrow and deducting from their account
			sorted_funds2.each do |key, value|
				value = value.round(2)
				transaction= Transaction.create!(:transfer_id => transfer.id, :lender_id => key,  :lend_amount => value)
				transaction.borrow

			end


			#add money to my balance
			my_new_balance= user.account.balance + transfer.amount
			user.account.update_attributes(:balance => my_new_balance)

			#subtract money from remaining borrow
			my_new_remaining_borrow= user.account.remaining_borrow - transfer.amount
			user.account.update_attributes(:remaining_borrow => my_new_remaining_borrow)

			return [transfer, "You just borrowed $#{total_borrow_amount}"]
		else
			return [false, "Please enter a message"]
		end
	end

	#make payment
	def self.update_transfer(update_params, user)
		#use current transfer 
		total_payment_amount= update_params[:amount].to_f
		current_transfer= user.account.transfers.find(update_params[:id])

		if total_payment_amount<0
			return [false, "Not a valid amount"]
		elsif total_payment_amount>current_transfer.amount
			return [false, "Payment is too much"]
		end

		
		current_transactions= current_transfer.transactions
		funds = current_transactions.pluck(:lender_id, :lend_amount).to_h

		

		sorted_funds = funds.sort_by{|u,l| l}
		sorted_funds = sorted_funds.to_h
		n=1
		payment_check = sorted_funds.first(n).map(&:second)

		local_total = 0
		local_total = payment_check.inject(:+)
		while local_total < total_payment_amount
			# if lending funds from bottom n friends is less then amount then
			# add 1 user onto number of lenders
			n +=1
			payment_check = sorted_funds.first(n).map(&:second)
			# sum up the amount of lending funds with new lender(s)
			local_total = payment_check.inject(:+)
			
		end
		
			# if total lending funds > total amount
			# subtract total lending funds from total amount
			# give that extra money back to the last user 
			if local_total > total_payment_amount
			local_total -= payment_check[-1]
			payment_check[-1] = (total_payment_amount-local_total)
			end
			
			payment_check[-1] = payment_check[-1].round(2)
			sorted_funds2 = sorted_funds.first(payment_check.length).to_h
			payment_check.each_index do |i|
				sorted_funds2[sorted_funds2.keys[i]] = payment_check[i]
			
			end
			
			
		
			sorted_funds2.each do |key, value|
				transaction= current_transfer.transactions.find_by(lender_id: key)
						new_transaction_amount = transaction.lend_amount- value
						new_transaction_amount = new_transaction_amount.round(2)
						transaction.update_attributes(lend_amount: new_transaction_amount)
						transaction.payment(value)

				
			end
			

			new_amount= current_transfer.amount- total_payment_amount
			if new_amount == 0
				transfer = current_transfer.update_attributes(amount: new_amount, completed: true)
			else
				transfer = current_transfer.update_attributes(amount: new_amount)
			end	
				user.account.remaining_borrow += total_payment_amount
				user.account.save
			return [transfer, "You have just made payment for $#{total_payment_amount}"]
	end

end
