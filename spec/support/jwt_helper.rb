module JwtHelper
  def generate_jwt(user_id:)
    payload = { user_id: user_id, exp: 1.day.from_now.to_i }

    JWT.encode(payload, Rails.application.credentials.jwt_secret, 'HS256')
  end
end
