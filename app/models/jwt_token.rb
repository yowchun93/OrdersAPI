class JwtToken
  HARDCODED_KEY = 'top_secret_key'

  def self.generate_token(payload)
    JWT.encode(payload, HARDCODED_KEY, 'HS256')
  end

  def self.validate_token(token)
    begin
      JWT.decode(token, HARDCODED_KEY, true, { algorithm: 'HS256' })
    rescue JWT::DecodeError
      false
    end
  end
end
