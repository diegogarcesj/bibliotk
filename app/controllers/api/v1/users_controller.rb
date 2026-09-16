module Api
  module V1
    class UsersController < BaseController
      def ban
        user = Users::Ban.call(User.find(params[:id]))

        render json: user_json(user)
      end

      def unban
        user = Users::Unban.call(User.find(params[:id]))

        render json: user_json(user)
      end

      private

      def user_json(user)
        {
          id: user.id,
          banned: user.banned?,
          banned_at: user.banned_at
        }
      end
    end
  end
end