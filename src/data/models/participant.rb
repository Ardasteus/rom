# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# E-Mail participant
		class Participant < Model
			property :id, Integer
			property :name, String
			property! :address, String
			property :contact, Contact
		end
	end
end