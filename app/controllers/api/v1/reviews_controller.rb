module Api
  module V1
    class ReviewsController < BaseController
      before_action :set_book

      def create
        review = Reviews::Create.call(
          current_user,
          @book,
          rating: review_params[:rating],
          content: review_params[:content]
        )

        render json: review_json(review), status: :created
      end

      def update
        review = current_user.reviews.find_by!(book: @book)

        review = Reviews::Update.call(
          review,
          rating: review_params[:rating],
          content: review_params[:content]
        )

        render json: review_json(review)
      end

      def destroy
        review = current_user.reviews.find_by!(book: @book)

        Reviews::Destroy.call(review)

        head :no_content
      end

      private

      def set_book
        @book = Book.find(params[:book_id])
      end

      def review_params
        params.require(:review).permit(:rating, :content)
      end

      def review_json(review)
        {
          id: review.id,
          book_id: review.book_id,
          rating: review.rating,
          content: review.content,
          created_at: review.created_at,
          updated_at: review.updated_at
        }
      end
    end
  end
end