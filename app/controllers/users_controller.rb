class UsersController < ApplicationController
	before_action :auth_user, except: [:new]

	def new 
	end

	def create
	end

	def edit
	end

	def update
	end

	def show
	end

	def delete
	end

	def dashboard
		@account = current_user.account
		@user = current_user
		if current_user.account.transfers 
			@transfers = current_user.account.transfers.where(completed: false)
		end
		if current_user.account.collateral
			@collateral = current_user.account.collateral*0.9
			@remaining = current_user.account.remaining_borrow
		end
	end
end

