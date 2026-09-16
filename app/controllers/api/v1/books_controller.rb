module Api
  module V1
    class BooksController < BaseController
      def index
        books = Book.order(:id)

        render json: books.map { |book| book_json(book) }
      end

      def show
        book = Book.find(params[:id])

        render json: book_json(book).merge(
          reviews: book.reviews
            .from_active_users
            .includes(:user)
            .order(created_at: :desc)
            .map { |review| review_json(review) }
        )
      end

      private

      def book_json(book)
        rating = book.rating_display

        {
          id: book.id,
          title: book.title,
          reviews_count: book.reviews_count,
          average_rating: rating[:average_rating],
          rating_label: rating[:rating_label]
        }
      end

      def review_json(review)
        {
          id: review.id,
          rating: review.rating,
          content: review.content,
          created_at: review.created_at
        }
      end
    end
  end
end