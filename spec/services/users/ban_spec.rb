require "rails_helper"

RSpec.describe Users::Ban do
  describe ".call" do
    it "excludes all reviews from the banned user" do
      user = User.create!
      other_user = User.create!

      first_book = Book.create!(title: "Dune")
      second_book = Book.create!(title: "Foundation")

      Reviews::Create.call(
        user,
        first_book,
        rating: 5,
        content: "Muy bueno"
      )

      Reviews::Create.call(
        user,
        second_book,
        rating: 4,
        content: "Bueno"
      )

      Reviews::Create.call(
        other_user,
        first_book,
        rating: 3,
        content: "Normal"
      )

      expect(first_book.reload.reviews_count).to eq(2)
      expect(first_book.reviews_sum).to eq(8)

      expect(second_book.reload.reviews_count).to eq(1)
      expect(second_book.reviews_sum).to eq(4)

      described_class.call(user)

      expect(user.reload.banned?).to be(true)

      first_book.reload
      second_book.reload

      expect(first_book.reviews_count).to eq(1)
      expect(first_book.reviews_sum).to eq(3)

      expect(second_book.reviews_count).to eq(0)
      expect(second_book.reviews_sum).to eq(0)

      expect(Review.count).to eq(3)
    end

    it "is idempotent when the user is already banned" do
      user = User.create!
    
      first_result = described_class.call(user)
      first_banned_at = first_result.banned_at
    
      second_result = described_class.call(user)
    
      expect(second_result.reload.banned?).to be(true)
      expect(second_result.banned_at).to eq(first_banned_at)
    end

    it "keeps the user's reviews stored" do
      user = User.create!
      book = Book.create!(title: "Dune")
    
      review = Reviews::Create.call(
        user,
        book,
        rating: 5,
        content: "Excelente"
      )
    
      expect {
        described_class.call(user)
      }.not_to change(Review, :count)
    
      expect(Review.find(review.id)).to be_present
    end
  end
end