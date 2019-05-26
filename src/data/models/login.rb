module ROM
	class Login < Model
		property :id, Integer
		property! :driver, TypeDriver
		property! :token, String
		property! :user, User
		property :last_logon, Integer
	end
end