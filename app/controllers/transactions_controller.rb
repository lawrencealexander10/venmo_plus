class TransactionsController < ApplicationController
  def new
  end

  def create
  	@transfer = Transfer.new
  end

  def edit
  end

  def update
  end
end
