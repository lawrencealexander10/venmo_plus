class AccountsController < ApplicationController
 
def edit
end


  def update
  	@account = current_user.account

	   @account.update_attributes(account_params)
     collateral =  @account.collateral
     lending_funds = @account.lending_funds
     borrow_limit = (collateral*0.9)
     @account.update_attributes(remaining_borrow: borrow_limit)
  	redirect_to root_path


  end


  def show
  end

  private

  def account_params
		params.require(:account).permit(:collateral, :lending_funds)
	end
end


