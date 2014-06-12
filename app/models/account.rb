class Account < ActiveRecord::Base
	belongs_to :user
	has_many :transfers
	has_many :transactions, through: :transfers
end
