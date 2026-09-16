module Api
  module V1
    module Me
      class ReviewsController < BaseController
        def index
          reviews = current_user.reviews
            .includes(:book)
            .order(created_at: :desc)

          render json: reviews.map { |review| review_json(review) }
        end

        private

        def review_json(review)
          {
            id: review.id,
            book_id: review.book_id,
            book_title: review.book.title,
            rating: review.rating,
            content: review.content,
            active: review.active?,
            created_at: review.created_at,
            updated_at: review.updated_at
          }
        end
      end
    end
  end
end