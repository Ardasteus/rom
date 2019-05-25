# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class CollectionMail < Model
		property! :mail, Mail, KeyAttribute[]
		property! :collection, Collection, KeyAttribute[]
	end
end