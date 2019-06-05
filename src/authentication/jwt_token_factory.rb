module ROM
	module Authentication
		module Factories
			class JWTTokenFactory < TokenFactory
				HASH = 'sha512'
				
				def initialize(itc)
					super(itc, 'jwt', JwtConfig)
					@header = {}
					@header[:typ] = "JWT"
					@header[:alg] = "RS512"
				end
				
				def config(conf)
					@rsa = OpenSSL::PKey::RSA.new(conf.rsa_size)
				end
				
				def issue_token(type, user, login, stamp)
					Token.new(type, user, login, stamp)
				end
				
				def to_string(token)
					base_64_header = Base64.urlsafe_encode64(JSON.generate(@header))
					body = {}
					body[:auth] = token.type
					body[:username] = token.login
					body[:security_stamp] = token.security_stamp
					body[:full_name] = token.user.full_name
					body[:first_name] = token.user.first_name
					body[:last_name] = token.user.last_name
					base_64_body = Base64.urlsafe_encode64(JSON.generate(body))
					rsa_to_sign = base_64_header + "." + base_64_body
					rsa_string = @rsa.sign_pss(HASH, rsa_to_sign.encode(Encoding.find('ASCII-8BIT')), salt_length: :max, mgf1_hash: HASH)
					str_token = ''
					str_token += base_64_header + "."
					str_token += base_64_body + "."
					str_token += Base64.urlsafe_encode64(rsa_string)
					
					str_token
				end
				
				def from_string(str)
					hdr, body, sig = str.split('.').collect { |i| Base64.urlsafe_decode64(i) }
					raise("JWT Token signature is invalid!") unless @rsa.verify_pss(HASH, sig, str.scan(/[^.]+\.[^.]+/).first.to_s, salt_length: :auto, mgf1_hash: HASH)
					
					hdr = JSON.parse(hdr)
					body = JSON.parse(body)
					@header.each_pair do |k, v|
						raise("JWT header not found '#{k}'!") unless hdr.has_key?(k.to_s)
						raise("JWT header '' is of unexpected value!") unless v == hdr[k.to_s]
					end
					
					Token.new(body['auth'], User.new(body['full_name'], body['first_name'], body['last_name']), body['username'], body['security_stamp'])
				end
			end
		end
	end
end