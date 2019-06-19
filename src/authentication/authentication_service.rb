module ROM
	module Authentication
		class AuthenticationService < ROM::Service
			ROOT = 'root'
			ROOT_DRIVER = '__root'
			ROOT_COST = 14
			
			def initialize(itc)
				super(itc, "Authentication Service", "Authenticates people", DbServer)
				@onion = {}
				
				@providers = @itc.lookup(ROM::Authentication::AuthenticationProvider)
				itc.hook(ROM::Authentication::AuthenticationProvider) do |prov|
					@providers.push(prov)
				end
				
				@itc = itc
				@db = itc.pin(DbServer)
				@log = itc.pin(LogServer)
				@config = @itc.pin(AuthenticationConfig)
				@tokens = nil
				@lifetime = nil
			end
			
			def resolve(username, password)
				return login_root(password) if username == ROOT
				
				@db.open(DB::RomDbContext) do |ctx|
					user = ctx.users.find { |i| i.login == username }
					if user != nil
						ctx.logins.select { |i| i.user == user }.each do |login|
							auth = @onion[login.driver]
							next if auth == nil
							
							u = auth.authenticate(login.login, password)
							login.last_logon = Time.now.to_i
							ctx.logins.update(login)
							return create_token(login.driver, login.generation, Identity.new(u, user.id, username, user.super == 1 ? true : false)) unless u == nil
						end
						
						return nil
					end
					
					@onion.each_pair do |k, v|
						next unless @config.config.onion[k].import
						
						user = v.authenticate(username, password)
						next if user == nil
						
						acc = import_user(ctx, username, k, user)
						
						return create_token(k, 0, Identity.new(user, acc.id, username, false))
					end
				end

				nil
			end
			
			def import_user(db, login, driver, user, sa = false)
				user = DB::User.create(db, login, user.first_name, user.last_name, sa)
				db.logins << DB::Login.new(:driver => driver, :user => user, :login => login, :last_logon => Time.now.to_i)
				
				user
			end
			
			def invalidate(str)
				token = @itc.fetch(ROM::Authentication::TokenFactory).from_string(str)
				
				return if token.expiry <= Time.now
				
				@db.open(DB::RomDbContext) do |ctx|
					login = ctx.logins.find { |i| i.driver == token.type }
					return if login == nil
					
					login.generation = token.generation + 1
					ctx.logins.save(login)
				end
			end
			
			def login_root(password)
				root = nil
				contact = nil
				login = nil
				@db.open(DB::RomDbContext) do |ctx|
					root = ctx.users.find { |i| i.login == ROOT }
					raise('Root user not found!') if root == nil
					
					login = ctx.logins.find { |i| (i.user == root).and(i.driver == ROOT_DRIVER) }
					pass = ctx.passwords.find { |i| i.login == login }
					
					return nil unless Authenticators::LocalAuthenticator.check_hash(pass.hash, password)
					login.last_logon = Time.now.to_i
					ctx.logins.update(login)
					contact = root.contact
				end
				
				create_token(ROOT_DRIVER, login.generation, Identity.new(User.new(contact.first_name, contact.first_name, contact.last_name), root.id, ROOT, true))
			end
			
			def create_token(type, stamp, id)
				fact = @itc.fetch(ROM::Authentication::TokenFactory)
				token = Token.new(type, id, stamp, Time.now + @lifetime)
				
				fact.to_string(token)
			end
			
			def validate(str)
				token = @itc.fetch(ROM::Authentication::TokenFactory).from_string(str)

				return nil if token.expiry <= Time.now

				token.identity
			end
			
			def up
				config = @config.config
				
				config.onion.each_pair do |name, model|
					provider = @providers.select { |prov| prov.is_name?(model.driver) }.first
					@onion[name] = provider.open(name, provider.config_model.from_object(model.config))
				end
				
				f = config.tokens.factory
				@tokens = @itc.fetch(TokenFactory) { |i| i.name == f }
				raise("Token factory '#{f}' not found!") if @tokens == nil
				@tokens.config(@tokens.config_model.from_object(config.tokens.config))
				
				@lifetime = config.tokens.lifetime
				
				@db.open(DB::RomDbContext) do |ctx|
					root = ctx.users.find { |u| u.login == ROOT }
					if root == nil
						pwd = Authenticators::LocalAuthenticator.rand_pwd
						@log.info("Creating root user with password '#{pwd}'...")
						root = import_user(ctx, ROOT, ROOT_DRIVER, User.new('Administrator', 'Administrator', nil), true)
						login = ctx.logins.find { |i| i.user == root }
						ctx.passwords << DB::Password.new(:login => login, :hash => Authenticators::LocalAuthenticator.get_hash(pwd, ROOT_COST))
					end
				end
			end
			
			def down
			end
		end
	end
end