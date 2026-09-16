require "rails_helper"

RSpec.describe Users::EstimateBanImpact, type: :service do
  describe ".call" do
    subject(:result) { described_class.call(user) }

    let(:user) { create(:user) }

    context "when the user has reviews" do
      let(:book_with_three_reviews) do
        create(
          :book,
          reviews_sum: 12,
          reviews_count: 3
        )
      end

      let(:book_with_four_reviews) do
        create(
          :book,
          reviews_sum: 14,
          reviews_count: 4
        )
      end

      let!(:user_review_one) do
        create(
          :review,
          user: user,
          book: book_with_three_reviews,
          rating: 4
        )
      end

      let!(:user_review_two) do
        create(
          :review,
          user: user,
          book: book_with_four_reviews,
          rating: 5
        )
      end

      it "returns the estimated impact without banning the user" do
        expect(result).to include(
          user_id: user.id,
          user_banned: false,
          affected_books_count: 2
        )

        expect(result[:books]).to contain_exactly(
          hash_including(
            book_id: book_with_three_reviews.id,
            book_title: book_with_three_reviews.title,
            user_rating: 4,
            current_reviews_count: 3,
            current_average_rating: 4.0,
            projected_reviews_count: 2,
            projected_average_rating: nil,
            projected_rating_label: "Reseñas Insuficientes"
          ),
          hash_including(
            book_id: book_with_four_reviews.id,
            book_title: book_with_four_reviews.title,
            user_rating: 5,
            current_reviews_count: 4,
            current_average_rating: 3.5,
            projected_reviews_count: 3,
            projected_average_rating: 3.0,
            projected_rating_label: nil
          )
        )
      end

      it "does not ban the user" do
        expect { result }
          .not_to change { user.reload.banned_at }

        expect(user.reload).not_to be_banned
      end

      it "does not modify the books aggregates" do
        expect { result }.not_to change {
          [
            book_with_three_reviews.reload.attributes.slice(
              "reviews_sum",
              "reviews_count"
            ),
            book_with_four_reviews.reload.attributes.slice(
              "reviews_sum",
              "reviews_count"
            )
          ]
        }
      end
    end

    context "when the user has no reviews" do
      it "returns an empty impact" do
        expect(result).to eq(
          user_id: user.id,
          user_banned: false,
          affected_books_count: 0,
          books: []
        )
      end

      it "does not ban the user" do
        expect { result }
          .not_to change { user.reload.banned_at }
      end
    end

    context "when the user is already banned" do
      let(:user) { create(:user, banned_at: Time.current) }

      let!(:review) do
        create(
          :review,
          user: user,
          rating: 5
        )
      end

      it "returns no additional impact" do
        expect(result).to eq(
          user_id: user.id,
          user_banned: true,
          affected_books_count: 0,
          books: []
        )
      end

      it "keeps the user banned" do
        expect { result }
          .not_to change { user.reload.banned_at }
      end
    end
  end
end