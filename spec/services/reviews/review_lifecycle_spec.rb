require "rails_helper"

RSpec.describe "Review lifecycle", type: :service do
  let(:user) { create(:user) }
  let(:book) { create(:book) }

  it "keeps the book aggregates consistent through create, update and destroy" do
    review = Reviews::Create.call(
      user,
      book,
      rating: 4,
      content: "Buen libro"
    )

    book.reload

    expect(book.reviews_sum).to eq(4)
    expect(book.reviews_count).to eq(1)

    Reviews::Update.call(
      review,
      rating: 5,
      content: "Excelente libro"
    )

    book.reload

    expect(book.reviews_sum).to eq(5)
    expect(book.reviews_count).to eq(1)

    Reviews::Destroy.call(review)

    book.reload

    expect(book.reviews_sum).to eq(0)
    expect(book.reviews_count).to eq(0)

    expect(Review.exists?(review.id)).to be(false)
  end

  it "replaces the previous rating when editing a review" do
    review = Reviews::Create.call(
      user,
      book,
      rating: 2,
      content: "Regular"
    )
  
    Reviews::Update.call(
      review,
      rating: 5,
      content: "Cambié de opinión"
    )
  
    book.reload
  
    expect(book.reviews_sum).to eq(5)
    expect(book.reviews_count).to eq(1)
  end
end