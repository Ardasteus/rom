module ROM
	module DB
		# A user login method
		class Login < Model
			property :id, Integer
			property! :driver, String
			property! :user, User
			property! :login, String
			property :last_logon, Integer
			property :generation, Integer, 0
		end
	end
end