# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# N:M mapping between mails and folders
		class CollectionMail < Model
			property! :mail, Mail, KeyAttribute[]
			property! :collection, Collection, KeyAttribute[]
		end
	end
end