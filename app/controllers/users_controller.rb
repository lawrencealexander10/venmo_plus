class UsersController < ApplicationController

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
		unless current_user
			redirect_to "/static/index"	
		end
		@user = current_user
	end
end
