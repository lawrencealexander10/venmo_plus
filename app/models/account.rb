class Account < ActiveRecord::Base
	belongs_to :user
	has_many :transfers
	has many :transactions through: :transfers
end
