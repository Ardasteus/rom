module
  class JWTTokenFactory < TokenFactory
    def initiliaze(itc)
      super(itc)
      header = {}
      header[:typ] = "JWT"
      header[:alg] = "RS512"

      rsa = OpenSSL::PKey::RSA.new(4096)
    end

    def to_token(user)
      body = {}
      body[:username] = user.username
      body[:security_stamp] = user.security_stamp
      body[:first_name] = user.first_name
      body[:last_name] = user.last_name
      base_64_header = urlsafe_encode64(json.generate(@header))
      base_64_body = urlsafe_encode64(json.generate(body))
      rsa_to_sign = base_64_header + "." + base_64_body
      rsa_string = @rsa.sign_pss('sha512', rsa_to_sign, salt_length: :max, mgf1_hash: 'sha512')
      token += base_64_header + "."
      token += base_64_body + "."
      token += urlsafe_encode64(rsa_string)
    end

    def from_token(token)
    end
  end
end