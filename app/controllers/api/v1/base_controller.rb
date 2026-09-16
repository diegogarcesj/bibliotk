module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
      rescue_from Users::BannedUserError, with: :render_banned_user
      rescue_from ActiveRecord::RecordNotUnique, with: :render_record_not_unique

      private

      def current_user
        @current_user ||= User.find(request.headers["X-User-Id"])
      end

      def render_not_found(exception)
        render json: {
          error: {
            code: "not_found",
            message: exception.message
          }
        }, status: :not_found
      end

      def render_record_invalid(exception)
        render json: {
          error: {
            code: "validation_error",
            message: exception.message,
            details: exception.record.errors.to_hash
          }
        }, status: :unprocessable_entity
      end

      def render_banned_user(_exception)
        render json: {
          error: {
            code: "banned_user",
            message: "El usuario está baneado y no puede modificar reseñas"
          }
        }, status: :forbidden
      end

      def render_record_not_unique(_exception)
        render json: {
          error: {
            code: "record_not_unique",
            message: "El usuario ya tiene una reseña para este libro"
          }
        }, status: :conflict
      end
    end
  end
end