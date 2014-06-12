class User < ActiveRecord::Base
	has_one :account
	has_many :transfers, through: :accounts
  has_many :transactions, through: :accounts
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable
  # validates :fname, :lname, presence: true
  validates :email, presence: true, uniqueness: true

  def self.from_omniauth(auth)
    User.where(auth.slice(:uid)).first_or_create do |user|
      user.uid = auth.uid
      user.fname = auth.extra.raw_info.firstname
      user.email = auth.info.email
      user.lname = auth.extra.raw_info.lastname
      user.profile_pic = auth.info.image
      user.token = auth.credentials.token

      account = user.account || Account.create(:user_id => user.id)
      account.balance = auth.info.balance
      account.save  
    end
  end

  def self.new_with_session(params, session)
	  if session["devise.user_attributes"]
	    new(session["devise.user_attributes"], without_protection: true) do |user|
	      user.attributes = params
	    end
	  else
	    super
	  end    
	end



end