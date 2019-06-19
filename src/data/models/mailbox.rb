# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# Mailbox
		class Mailbox < Model
			property :id, Integer
			property! :name, String
			property! :address, String
			property! :author, String
			property! :owner, User, SuffixAttribute['owner']
			property! :drafts, Collection, SuffixAttribute['drafts']
			property! :outbox, Collection, SuffixAttribute['outbox']
			property :imap, Connection, SuffixAttribute['imap']
			property :smtp, Connection, SuffixAttribute['smtp']
		end
	end
end