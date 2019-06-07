# Created by Matyáš Pokorný on 2019-06-05.

module ROM
	module Authentication
		module Authenticators
			class LocalAuthenticator < Authenticator
				PASSWORD_CHARS = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z - . _)
				
				def initialize(db, conf)
					@db = db
					@conf = conf
				end
				
				def authenticate(username, password)
				
				end
				
				def self.get_hash(pwd, cost)
					BCrypt::Password.create(pwd, :cost => cost).to_s
				end
				
				def self.check_hash(hash, pwd)
					BCrypt::Password.new(hash) == pwd
				end
				
				def self.rand_pwd(len = 12)
					ret = ''
					len.times do |i|
						c = PASSWORD_CHARS[(rand * PASSWORD_CHARS.length).floor]
						c = c.upcase if rand < 0.5
						ret += c
					end
					
					ret
				end
			end
		end
	end
end