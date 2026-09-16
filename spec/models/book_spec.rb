require "rails_helper"

RSpec.describe Book, type: :model do
  describe "#rating_display" do
    context "when testing half-up rounding boundaries" do
      it "rounds 4.25 up to 4.3" do
        book = build(
          :book,
          reviews_sum: 17,
          reviews_count: 4
        )

        expect(book.rating_display).to eq(
          average_rating: 4.3,
          rating_label: nil
        )
      end

      it "rounds 4.24 down to 4.2" do
        # 106 / 25 = 4.24
        book = build(
          :book,
          reviews_sum: 106,
          reviews_count: 25
        )

        expect(book.rating_display).to eq(
          average_rating: 4.2,
          rating_label: nil
        )
      end

      it "rounds 4.15 up to 4.2" do
        # 83 / 20 = 4.15
        book = build(
          :book,
          reviews_sum: 83,
          reviews_count: 20
        )

        expect(book.rating_display).to eq(
          average_rating: 4.2,
          rating_label: nil
        )
      end
    end

    context "when the book has fewer than three reviews" do
      it "returns insufficient reviews with zero reviews" do
        book = build(
          :book,
          reviews_sum: 0,
          reviews_count: 0
        )
  
        expect(book.rating_display).to eq(
          average_rating: nil,
          rating_label: "Reseñas Insuficientes"
        )
      end
  
      it "returns insufficient reviews with two reviews" do
        book = build(
          :book,
          reviews_sum: 9,
          reviews_count: 2
        )
  
        expect(book.rating_display).to eq(
          average_rating: nil,
          rating_label: "Reseñas Insuficientes"
        )
      end
    end
  
    context "when the book reaches three reviews" do
      it "starts displaying the average rating" do
        book = build(
          :book,
          reviews_sum: 13,
          reviews_count: 3
        )
  
        expect(book.rating_display).to eq(
          average_rating: 4.3,
          rating_label: nil
        )
      end
    end
  end
end