# Created by Matyáš Pokorný on 2019-05-25.

module ROM
	module DB
		# Group of contacts
		class ContactGroup < Model
			property :id, Integer
			property! :name, String, IndexAttribute[]
			property! :user, User, SuffixAttribute['owner']
			property! :personal, Integer, LengthAttribute[1]
		end
	end
end