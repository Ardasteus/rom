# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# E-Mail participant
		class Participant < Model
			property :id, Integer
			property :name, String
			property! :address, String
			property :contact, Contact
			property :references, Integer, 1
			
			def tag
				ret = nil
				ret = name if name != nil
				if ret == nil
					ret = address
				else
					ret = "#{ret} <#{address}>"
				end
				
				ret
			end
		end
	end
end