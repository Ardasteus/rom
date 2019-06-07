module ROM
	module Authentication
		module Factories
			class JWTTokenFactory < TokenFactory
				HASH = 'sha512'
				
				HEADER_TYPE = 'typ'
				HEADER_ALGORITHM = 'alg'
				
				CLAIM_ISSUER = 'iss'
				CLAIM_AUTHORIZATION = 'auth'
				CLAIM_SUBJECT = 'sub'
				CLAIM_TIMESTAMP = 'iat'
				CLAIM_STAMP = 'stamp'
				CLAIM_CANONICAL_NAME = 'cn'
				CLAIM_FIRST_NAME = 'fn'
				CLAIM_LAST_NAME = 'ln'
				CLAIM_EXPIRY = 'exp'
				CLAIM_SUPER = 'sup'
				
				def initialize(itc)
					super(itc, 'jwt', JwtConfig)
					@header = {
						HEADER_TYPE => 'JWT',
						HEADER_ALGORITHM => 'RS512'
					}
					@iss = nil
				end
				
				def config(conf)
					@rsa = OpenSSL::PKey::RSA.new(conf.rsa_size)
					@iss = conf.issuer
				end
				
				def to_string(token)
					base_64_header = Base64.urlsafe_encode64(JSON.generate(@header))
					body = {
						CLAIM_ISSUER => @iss,
						CLAIM_AUTHORIZATION => token.type,
						CLAIM_SUBJECT => token.identity.login,
						CLAIM_TIMESTAMP => Time.now.to_i,
						CLAIM_STAMP => token.security_stamp.to_i,
						CLAIM_CANONICAL_NAME => token.identity.user.full_name,
						CLAIM_FIRST_NAME => token.identity.user.first_name,
						CLAIM_LAST_NAME => token.identity.user.last_name,
						CLAIM_EXPIRY => token.expiry.to_i,
						CLAIM_SUPER => token.identity.super
					}
					base_64_body = Base64.urlsafe_encode64(JSON.generate(body))
					rsa_to_sign = base_64_header + "." + base_64_body
					rsa_string = @rsa.sign_pss(HASH, rsa_to_sign.encode(Encoding.find('ASCII-8BIT')), salt_length: :max, mgf1_hash: HASH)
					
					"#{base_64_header}.#{base_64_body}.#{Base64.urlsafe_encode64(rsa_string)}"
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
					
					Token.new(
						body[CLAIM_AUTHORIZATION],
						Identity.new(
							User.new(
								body[CLAIM_CANONICAL_NAME],
								body[CLAIM_FIRST_NAME],
								body[CLAIM_LAST_NAME]
							),
							body[CLAIM_SUBJECT],
							body[CLAIM_SUPER]
						),
						body[CLAIM_STAMP],
						Time.at(body[CLAIM_EXPIRY])
					)
				end
			end
		end
	end
end