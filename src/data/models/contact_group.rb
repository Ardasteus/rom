# Created by Matyáš Pokorný on 2019-05-25.

module ROM
	class ContactGroup < Model
		property :id, Integer
		property! :name, String, IndexAttribute[]
		property! :user, User, SuffixAttribute['owner']
		property! :personal, Types::Boolean
	end
end