# Created by Matyáš Pokorný on 2019-05-25.

module ROM
	module DB
		# N:M mapping table between contacts and groups
		class ContactContactGroup < Model
			property! :contact, Contact, KeyAttribute[]
			property! :contact_group, ContactGroup, KeyAttribute[]
		end
	end
end