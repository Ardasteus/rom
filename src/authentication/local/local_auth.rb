# Created by Matyáš Pokorný on 2019-06-05.

module ROM
	module Authentication
		module Authenticators
			class LocalAuthenticator < Authenticator
				PASSWORD_CHARS = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z - . _)
				
				def initialize(db, name, conf)
					@db = db
					@name = name
					@conf = conf
				end
				
				def authenticate(username, password)
					@db.open(DB::RomDbContext) do |ctx|
						login = ctx.logins.find { |i| (i.login == username).and(i.driver == @name) }
						return nil if login == nil
						
						pwd = ctx.passwords.find(login.id)
						return nil if pwd == nil or not LocalAuthenticator.check_hash(pwd.hash, password)
						
						if LocalAuthenticator.hash_cost(pwd.hash) != @conf.cost
							pwd.hash = LocalAuthenticator.get_hash(pwd.hash, @conf.cost)
							ctx.passwords.update(pwd)
						end
						
						contact = login.user.contact
						
						cn = contact.first_name
						cn += " #{contact.last_name}" if contact.last_name != nil
						
						return User.new(cn, contact.first_name, contact.last_name)
					end
				end
				
				def create_user(login, pwd, fn, ln, sa = false)
					@db.open(DB::RomDbContext) do |ctx|
						user = DB::User.create(ctx, login, fn, ln, sa)
						login = DB::Login.new(:driver => @name, :user => user, :login => login)
						ctx.passwords << DB::Password.new(:login => login, :hash => LocalAuthenticator.get_hash(pwd, @conf.cost))
						
						return user
					end
				end
				
				def self.get_hash(pwd, cost)
					BCrypt::Password.create(pwd, :cost => cost).to_s
				end
				
				def self.check_hash(hash, pwd)
					BCrypt::Password.new(hash) == pwd
				end
				
				def self.hash_cost(hash)
					BCrypt::Password.new(hash).cost
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