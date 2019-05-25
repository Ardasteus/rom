# Created by Matyáš Pokorný on 2019-05-25.

module ROM
	class ContactGroupUser < Model
		property :id, Integer
		property! :contact_group, ContactGroup
		property! :can_edit, Types::Boolean
	end
end