# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class Mailbox < Model
		property :id, Integer
		property! :name, String
		property! :address, String
		property! :author, String
		property! :owner, User, SuffixAttribute['owner']
		property :imap, Connection, SuffixAttribute['imap']
		property :smtp, Connection, SuffixAttribute['smtp']
	end
end