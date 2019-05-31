# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# N:M mapping between folders and mailboxes
		class Map < Model
			property :mailbox, Mailbox, KeyAttribute[]
			property :collection, Collection, KeyAttribute[]
			property :filter, String
		end
	end
end