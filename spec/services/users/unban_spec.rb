require "rails_helper"

RSpec.describe Users::Unban do
  describe ".call" do
    it "restores the user's reviews after unbanning" do
      user = User.create!
      book = Book.create!(title: "Dune")

      Reviews::Create.call(
        user,
        book,
        rating: 5,
        content: "Excelente"
      )

      Users::Ban.call(user)

      expect(book.reload.reviews_count).to eq(0)
      expect(book.reviews_sum).to eq(0)

      described_class.call(user)

      expect(user.reload.banned?).to be(false)

      book.reload

      expect(book.reviews_count).to eq(1)
      expect(book.reviews_sum).to eq(5)
    end

    it "is idempotent when the user is not banned" do
      user = User.create!
    
      result = described_class.call(user)
    
      expect(result.reload.banned?).to be(false)
      expect(result.banned_at).to be_nil
    end
  end
end