module ROM
	module DB
		# User
		class User < Model
			property :id, Integer
			property! :login, String
			property! :collection, Collection
			property! :contact, Contact
			property :super, Integer, 0, LengthAttribute[1]
		end
	end
end