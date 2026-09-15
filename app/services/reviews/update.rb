module Reviews
  class Update
    def self.call(review, rating:, content:)
      new(
        review,
        rating:,
        content:
      ).call
    end

    def initialize(review, rating:, content:)
      @review = review
      @rating = rating
      @content = content
    end

    def call
      Review.transaction do
        user = User.lock.find(@review.user_id)

        raise Users::BannedUserError if user.banned?

        book = Book.lock.find(@review.book_id)
        review = Review.lock.find(@review.id)

        review.update!(
          rating: @rating,
          content: @content
        )

        Books::RebuildReviewStats.call(book)

        review
      end
    end
  end
end