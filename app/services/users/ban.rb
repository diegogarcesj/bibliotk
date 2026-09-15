module Users
  class Ban
    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      User.transaction do
        user = User.lock.find(@user.id)

        return user if user.banned?

        book_ids = user.reviews
          .distinct
          .order(:book_id)
          .pluck(:book_id)

        books = Book
          .where(id: book_ids)
          .order(:id)
          .lock
          .to_a

        user.update!(
          banned_at: Time.current
        )

        books.each do |book|
          Books::RebuildReviewStats.call(book)
        end

        user
      end
    end
  end
end