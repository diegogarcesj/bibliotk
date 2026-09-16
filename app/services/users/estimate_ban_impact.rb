module Users
  class EstimateBanImpact
    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      return empty_result if @user.banned?

      reviews = @user.reviews
        .includes(:book)
        .order(:book_id)
    
      {
        user_id: @user.id,
        user_banned: false,
        affected_books_count: reviews.size,
        books: reviews.map do |review|
          build_book_impact(review.book, review)
        end
      }
    end

    private

    def empty_result
      {
        user_id: @user.id,
        user_banned: true,
        affected_books_count: 0,
        books: []
      }
    end

    def build_book_impact(book, review)
      current_rating = book.rating_display[:average_rating]

      projected_count = book.reviews_count - 1
      projected_sum = book.reviews_sum - review.rating

      projected_rating =
        rating_display(
          sum: projected_sum,
          count: projected_count
        )

      {
        book_id: book.id,
        book_title: book.title,
        user_rating: review.rating,
        current_reviews_count: book.reviews_count,
        current_average_rating: current_rating,
        projected_reviews_count: projected_count,
        projected_average_rating: projected_rating[:average_rating],
        projected_rating_label: projected_rating[:rating_label],
        average_rating_change: average_rating_change(
          current_rating,
          projected_rating[:average_rating]
        )
      }
    end

    def rating_display(sum:, count:)
      if count < Book::MINIMUM_REVIEWS_FOR_RATING
        {
          average_rating: nil,
          rating_label: "Reseñas Insuficientes"
        }
      else
        average = BigDecimal(sum.to_s) / count

        {
          average_rating: average
            .round(1, BigDecimal::ROUND_HALF_UP)
            .to_f,
          rating_label: nil
        }
      end
    end

    def average_rating_change(current_rating, projected_rating)
      return nil if current_rating.nil? || projected_rating.nil?

      (projected_rating - current_rating).round(1)
    end
  end
end