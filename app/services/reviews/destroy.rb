module Reviews
  class Destroy
    def self.call(review)
      new(review).call
    end

    def initialize(review)
      @review = review
    end

    def call
      Review.transaction do
        user = User.lock.find(@review.user_id)

        raise Users::BannedUserError if user.banned?

        book = Book.lock.find(@review.book_id)
        review = Review.lock.find(@review.id)

        review.destroy!

        Books::RebuildReviewStats.call(book)
      end
    end
  end
end