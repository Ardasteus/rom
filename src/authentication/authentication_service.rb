module ROM
	module Authentication
		class AuthenticationService < ROM::Service
			ROOT = 'root'
			ROOT_DRIVER = '__root'
			
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
							
							user = auth.authenticate(login.login, password)
							login.last_logon = Time.now.to_i
							return create_token(login.driver, username, user) unless user == nil
						end
						
						return nil
					end
					
					@onion.each_pair do |k, v|
						next unless @config.config.onion[k].import
						
						user = v.authenticate(username, password)
						next if user == nil
						
						import_user(ctx, username, k, user)
						
						return create_token(k, username, user)
					end
				end

				nil
			end
			
			def import_user(db, login, driver, user)
				root = db.collections << DB::Collection.new(:name => '/')
				contact = db.contacts << DB::Contact.new(:first_name => user.first_name, :last_name => user.last_name)
				user = db.users << DB::User.new(:login => login, :collection => root, :contact => contact, :super => 1)
				db.logins << DB::Login.new(:driver => driver, :user => user, :login => login, :last_logon => Time.now.to_i)
				%w(inbox sent spam trash).each do |folder|
					db.collections << DB::Collection.new(:name => folder, :collection => root)
				end
				
				user
			end
			
			def login_root(password)
				contact = nil
				@db.open(DB::RomDbContext) do |ctx|
					root = ctx.users.find { |i| i.login == ROOT }
					raise('Root user not found!') if root == nil
					
					login = ctx.logins.find { |i| (i.user == root).and(i.driver == ROOT_DRIVER) }
					login.last_logon = Time.now.to_i
					pass = ctx.passwords.find { |i| i.login == login }
					
					return nil unless Authenticators::LocalAuthenticator.check_hash(pass.hash, password)
					contact = root.contact
				end
				
				create_token('local', ROOT, User.new(contact.first_name, contact.first_name, contact.last_name))
			end
			
			def create_token(type, login, user)
				fact = @itc.fetch(ROM::Authentication::TokenFactory)
				token = Token.new(type, user, login, Time.now, Time.now + @lifetime)
				
				fact.to_string(token)
			end
			
			def validate(str)
				token = @itc.fetch(ROM::Authentication::TokenFactory).from_string(str)

				return nil if token.expiry <= Time.now

				token.user
			end
			
			def up
				config = @config.config
				
				config.onion.each_pair do |name, model|
					provider = @providers.select { |prov| prov.is_name?(name) }.first
					@onion[name] = provider.open(provider.config_model.from_object(model.config))
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
						root = import_user(ctx, ROOT, ROOT_DRIVER, User.new('Administrator', 'Administrator', nil))
						login = ctx.logins.find { |i| i.user == root }
						ctx.passwords << DB::Password.new(:login => login, :hash => Authenticators::LocalAuthenticator.get_hash(pwd, 12))
					end
				end
			end
			
			def down
			end
		end
	end
end