module ROM
	class Contact < Model
		property :id, Integer
		property! :first_name, String
		property :last_name, String
		property :references, Integer, 1
	end
end