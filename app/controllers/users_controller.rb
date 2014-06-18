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
		@transfers= current_user.account.transfer
	end
end

