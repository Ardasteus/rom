# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# E-Mail address of a contact
		class ContactAddress < Model
			property :id, Integer
			property! :type, TypeAddress
			property! :name, String
			property! :address, String, IndexAttribute[]
			property! :contact, Contact
		end
	end
end