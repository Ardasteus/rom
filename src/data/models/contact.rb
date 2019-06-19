module ROM
	module DB
		# Contact
		class Contact < Model
			property :id, Integer
			property! :first_name, String
			property :last_name, String
			property :references, Integer, 1
			
			def full_name
				fn = first_name
				if last_name != nil
					fn += ' ' if fn.length > 0
					fn += last_name
				end
				
				fn
			end
		end
	end
end