module ROM
	module DB
		# A user login method
		class Login < Model
			property :id, Integer
			property! :driver, TypeDriver
			property! :token, String
			property! :user, User
			property :last_logon, Integer
		end
	end
end