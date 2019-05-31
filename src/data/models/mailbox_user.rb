# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# N:M mapping between users and mailboxes
		class MailboxUser < Model
			property! :mailbox, Mailbox, KeyAttribute[]
			property! :user, User, KeyAttribute[]
			property! :can_write, Types::Boolean
		end
	end
end