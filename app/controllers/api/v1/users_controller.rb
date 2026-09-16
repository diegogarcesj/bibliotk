module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: %i[ban unban ban_impact]

      def ban
        user = Users::Ban.call(@user)

        render json: user_json(user)
      end

      def unban
        user = Users::Unban.call(@user)

        render json: user_json(user)
      end

      def ban_impact
        impact = Users::EstimateBanImpact.call(@user)

        render json: impact, status: :ok
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

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