module ROM
	module DB
		# User
		class User < Model
			property :id, Integer
			property! :login, String
			property! :first_name, String
			property :last_name, String
			property! :collection, Collection
			property! :contact, Contact
		end
	end
end