class User < ApplicationRecord
  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :favourites, dependent: :destroy


  validates :name, :email, presence: true 
  validates :email, uniqueness: true

  has_one_attached :profile_picture
end
