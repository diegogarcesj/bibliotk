require "rails_helper"

RSpec.describe Reviews::Create do
  self.use_transactional_tests = false
  
  describe "concurrent reviews for the same book" do
    it "keeps the book statistics consistent with 200 concurrent users" do
      book = Book.create!(title: "Dune")

      users = 200.times.map do
        User.create!
      end

      ratings = users.map.with_index do |_user, index|
        (index % 5) + 1
      end

      jobs = users.zip(ratings)

      workers = 20.times.map do
        Thread.new do
          while (job = jobs.pop)
            user, rating = job

            Reviews::Create.call(
              user,
              book,
              rating: rating,
              content: nil
            )
          end
        end
      end

      workers.each(&:join)

      book.reload

      expect(book.reviews_count).to eq(200)
      expect(book.reviews_sum).to eq(ratings.sum)
      expect(book.average_rating).to eq(
        BigDecimal(ratings.sum.to_s) / 200
      )
    end
  end
end