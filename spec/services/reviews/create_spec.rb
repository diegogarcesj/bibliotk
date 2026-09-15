require "rails_helper"

RSpec.describe Reviews::Create do
  let(:user) { User.create! }
  let(:book) { Book.create!(title: "Dune") }

  it "creates a review" do
    review = described_class.call(
      user,
      book,
      rating: 5,
      content: "Excelente libro"
    )

    expect(review).to be_persisted
    expect(review.rating).to eq(5)
    expect(review.content).to eq("Excelente libro")
  end

  it "updates the book statistics" do
    described_class.call(
      user,
      book,
      rating: 5,
      content: nil
    )

    book.reload

    expect(book.reviews_count).to eq(1)
    expect(book.reviews_sum).to eq(5)
  end

  it "does not allow a banned user to create a review" do
    user.update!(banned_at: Time.current)

    expect {
      described_class.call(
        user,
        book,
        rating: 5,
        content: nil
      )
    }.to raise_error(Users::BannedUserError)

    expect(Review.count).to eq(0)
  end
end