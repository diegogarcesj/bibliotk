require "rails_helper"

RSpec.describe Users::Ban, type: :service do
  describe ".call" do
    let(:user) { create(:user) }

    let(:book) do
      create(
        :book,
        reviews_sum: 12,
        reviews_count: 3
      )
    end

    let!(:user_review) do
      create(
        :review,
        user: user,
        book: book,
        rating: 5
      )
    end

    let!(:other_review_one) do
      create(
        :review,
        user: create(:user),
        book: book,
        rating: 4
      )
    end

    let!(:other_review_two) do
      create(
        :review,
        user: create(:user),
        book: book,
        rating: 3
      )
    end

    it "bans the user" do
      expect {
        described_class.call(user)
      }.to change {
        user.reload.banned?
      }.from(false).to(true)
    end

    it "preserves the user's reviews" do
      expect {
        described_class.call(user)
      }.not_to change(Review, :count)

      expect(user_review.reload).to be_persisted
    end

    it "removes the banned user's rating from the book aggregates" do
      described_class.call(user)

      book.reload

      expect(book.reviews_sum).to eq(7)
      expect(book.reviews_count).to eq(2)
    end

    it "causes the book to fall below the public rating threshold" do
      described_class.call(user)

      expect(book.reload.rating_display).to eq(
        average_rating: nil,
        rating_label: "Reseñas Insuficientes"
      )
    end

    it "is idempotent when the user is already banned" do
      described_class.call(user)

      expect(user.reload).to be_banned

      expect {
        described_class.call(user)
      }.not_to change {
        user.reload.banned?
      }
    end
  end
end
