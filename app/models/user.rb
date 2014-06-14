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
  #validetes :uid, uniqueness: true

  after_create :create_account

  def self.from_omniauth(auth)
    user = User.where(auth.slice(:uid)).first_or_create do |user|
      user.uid = auth.uid
      user.fname = auth.info.first_name
      user.email = auth.info.email
      user.lname = auth.info.last_name
      user.profile_pic = auth.extra.raw_info.profile_picture_url
      user.token = auth.credentials.token     
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

  protected

  def create_account
    Account.create!(:user_id => self.id, :balance => 500)
  end

end