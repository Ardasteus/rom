module ROM
  module Authentication
    module Factories
      class JWTTokenFactory < TokenFactory
        def initialize(itc)
          super(itc)
          @header = {}
          @header[:typ] = "JWT"
          @header[:alg] = "RS512"

          @rsa = OpenSSL::PKey::RSA.new(4096)
        end

        def issue_token(user, login, stamp)
          Token.new(user, login, stamp)
        end

        def to_string(token)
          base_64_header = Base64.urlsafe_encode64(JSON.generate(@header))
          body = {}
          body[:username] = token.login
          body[:security_stamp] = token.security_stamp
          body[:full_name] = token.user.full_name
          body[:first_name] = token.user.first_name
          body[:last_name] = token.user.last_name
          base_64_body = Base64.urlsafe_encode64(JSON.generate(body))
          rsa_to_sign = base_64_header + "." + base_64_body
          rsa_string = @rsa.sign_pss('sha512', rsa_to_sign, salt_length: :max, mgf1_hash: 'sha512')
          str_token = ''
          str_token += base_64_header + "."
          str_token += base_64_body + "."
          str_token += Base64.urlsafe_encode64(rsa_string)
          
					str_token
        end

        def from_string(string)

        end
      end
    end
  end
end