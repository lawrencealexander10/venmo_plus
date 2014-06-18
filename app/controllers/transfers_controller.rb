class TransfersController < ApplicationController
  def index
  end

  def new
    @user = current_user
  	@transfer= Transfer.new
  end

  def create
  	@user= current_user
    result = Transfer.create_transfer(transfer_params, @user)
    if result[0]
      flash[:success] = result[1]
      redirect_to "/"
    else
      @transfer = Transfer.new(transfer_params)
      flash[:error] = result[1]
      render "transfers/new"
    end
  end

  def update
    @user= current_user
    result = Transfer.update_transfer(update_params, @user)
  end

  def edit
  	@transfer = current_user.account.transfer.where(:id =>params[:id])
  	@transfer = @transfer.amount
  end


private
 def transfer_params
    params.require(:transfer).permit(:amount, :message)
  end

def update_params
	params.require(:transfer).permit(:amount)
end


end
