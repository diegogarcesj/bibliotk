class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, length: { maximum: 1000 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :book_id }

  scope :from_active_users, -> { joins(:user).where(users: { banned_at: nil }) }

  def active?
    !user.banned?
  end
end
