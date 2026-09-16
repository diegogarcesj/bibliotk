require "rails_helper"

RSpec.describe Review, type: :model do
  self.use_transactional_tests = false

  after do
    Review.delete_all
    User.delete_all
    Book.delete_all
  end

  describe "concurrent uniqueness" do
    it "allows only one review per user and book" do
      user = create(:user)
      book = create(:book)

      results = Queue.new

      threads = 2.times.map do
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            begin
              Review.create!(
                user_id: user.id,
                book_id: book.id,
                rating: 5,
                content: "Concurrent review"
              )

              results << :created
            rescue ActiveRecord::RecordNotUnique,
                   ActiveRecord::RecordInvalid
              results << :rejected
            end
          end
        end
      end

      threads.each(&:join)

      outcomes = 2.times.map { results.pop }

      expect(outcomes.count(:created)).to eq(1)
      expect(outcomes.count(:rejected)).to eq(1)

      expect(
        Review.where(
          user_id: user.id,
          book_id: book.id
        ).count
      ).to eq(1)
    end
  end
end