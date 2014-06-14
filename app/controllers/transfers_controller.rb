class TransfersController < ApplicationController
  def index
  end

  def new
  	@transfers= Transfer.new
  end

  def create
  end

  def delete
  end
end
