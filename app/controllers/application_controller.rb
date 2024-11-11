class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    token = extract_token_from_header

    render json: { error: 'Unauthorized' }, status: :unauthorized unless valid_token?(token)
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    return nil unless header

    header.split(' ').last
  end

  def valid_token?(token)
    begin
      JWT.decode(token, Rails.application.credentials.jwt_secret, true, { algorithm: 'HS256' })
    rescue JWT::DecodeError
      false
    end
  end
end
