class User < ApplicationRecord # rubocop:todo Layout/EndOfLine
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tools

  def admin?
    admin
  end


end
