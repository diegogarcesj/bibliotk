class Book < ApplicationRecord
  has_many :reviews, dependent: :restrict_with_error

  validates :title, presence: true
  validates :reviews_sum, numericality: { greater_than_or_equal_to: 0 }
  validates :reviews_count, numericality: { greater_than_or_equal_to: 0 }

  MINIMUM_REVIEWS_FOR_RATING = 3

  def average_rating
    return nil if reviews_count.zero?

    BigDecimal(reviews_sum.to_s) / reviews_count
  end

  def rating_display
    if reviews_count < MINIMUM_REVIEWS_FOR_RATING
      {
        average_rating: nil,
        rating_label: "Reseñas Insuficientes"
      }
    else
      {
        average_rating: average_rating.round(1, BigDecimal::ROUND_HALF_UP).to_f,
        rating_label: nil
      }
    end
  end
end
