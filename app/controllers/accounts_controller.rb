class AccountsController < ApplicationController
 
def edit
end


  def update
  	@account = current_user.account

	@account.update_attributes(account_params)
  	redirect_to root_path
  end


  def show
  end

  private

  def account_params
		params.require(:account).permit(:collateral, :lending_funds)
	end
end


