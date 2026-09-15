require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "#rating_display" do
    it "rounds 3.25 to 3.3 using half-up rounding" do
      book = described_class.new(
        reviews_sum: 13,
        reviews_count: 4
      )

      expect(book.rating_display).to eq(
        average_rating: 3.3,
        rating_label: nil
      )
    end

    it "shows insufficient reviews below three reviews" do
      book = described_class.new(
        reviews_sum: 8,
        reviews_count: 2
      )

      expect(book.rating_display).to eq(
        average_rating: nil,
        rating_label: "Reseñas Insuficientes"
      )
    end

    it "shows the numeric rating with exactly three reviews" do
      book = described_class.new(
        reviews_sum: 12,
        reviews_count: 3
      )

      expect(book.rating_display).to eq(
        average_rating: 4.0,
        rating_label: nil
      )
    end
  end
end
