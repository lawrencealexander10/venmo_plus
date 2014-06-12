class Transfer < ActiveRecord::Base
	belongs_to :account
	has_many :transactions
	#does anything go here in respect to user
end
