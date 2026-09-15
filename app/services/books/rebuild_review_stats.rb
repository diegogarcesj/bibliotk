module Books
  class RebuildReviewStats
    def self.call(book)
      new(book).call
    end

    def initialize(book)
      @book = book
    end

    def call
      @book.with_lock do
        sum, count = Review
          .joins(:user)
          .where(book_id: @book.id)
          .where(users: { banned_at: nil })
          .pick(
            Arel.sql("COALESCE(SUM(reviews.rating), 0)"),
            Arel.sql("COUNT(reviews.id)")
          )

        @book.update!(
          reviews_sum: sum,
          reviews_count: count
        )
      end

      @book
    end
  end
end