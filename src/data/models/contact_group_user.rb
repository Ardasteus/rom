# Created by Matyáš Pokorný on 2019-05-25.

module ROM
	module DB
		# N:M mapping between users and contact group
		class ContactGroupUser < Model
			property! :user, User, KeyAttribute[]
			property! :contact_group, ContactGroup, KeyAttribute[]
			property! :can_edit, Integer, LengthAttribute[1]
		end
	end
end