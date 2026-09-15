module Reviews
  class Create
    def self.call(user, book, rating:, content:)
      new(
        user,
        book,
        rating:,
        content:
      ).call
    end

    def initialize(user, book, rating:, content:)
      @user = user
      @book = book
      @rating = rating
      @content = content
    end

    def call
      Review.transaction do
        user = User.lock.find(@user.id)

        raise Users::BannedUserError if user.banned?

        book = Book.lock.find(@book.id)

        review = Review.create!(
          user: user,
          book: book,
          rating: @rating,
          content: @content
        )

        Books::RebuildReviewStats.call(book)

        review
      end
    end
  end
end