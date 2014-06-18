class Account < ActiveRecord::Base
	belongs_to :user
	has_many :transfers, :dependent => :destroy
	has_many :transactions, through: :transfers, :dependent => :destroy
end
