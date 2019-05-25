# Created by Matyáš Pokorný on 2019-05-25.

module ROM
	class ContactContactGroup < Model
		property! :contact, Contact, KeyAttribute[]
		property! :contact_group, ContactGroup, KeyAttribute[]
	end
end