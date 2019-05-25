# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class ContactAddress < Model
		property :id, Integer
		property! :type, TypeAddress
		property! :name, String
		property! :address, String, IndexAttribute[]
		property! :contact, Contact
	end
end