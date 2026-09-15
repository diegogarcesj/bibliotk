class User < ApplicationRecord
  has_many :reviews, dependent: :restrict_with_error

  def banned?
    banned_at.present?
  end
end
