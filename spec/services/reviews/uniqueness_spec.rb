require "rails_helper"

RSpec.describe "Review uniqueness" do
  let(:user) { User.create! }
  let(:book) { Book.create!(title: "Dune") }

  it "allows only one review per user and book" do
    Reviews::Create.call(
      user,
      book,
      rating: 5,
      content: nil
    )

    expect {
      Reviews::Create.call(
        user,
        book,
        rating: 4,
        content: nil
      )
    }.to raise_error(ActiveRecord::RecordInvalid)

    expect(Review.count).to eq(1)
  end
end