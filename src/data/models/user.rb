module ROM
	class User < Model
		property :id, Integer
		property! :frist_name, String
		property :last_name, String
		property! :collection, Collection
		property! :contact, Contact
	end
end