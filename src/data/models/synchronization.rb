# Created by Matyáš Pokorný on 2019-06-20.

module ROM
	module DB
		class Synchronization < Model
			property! :id, Integer
			property! :connection, Connection
			property! :mailbox, Mailbox
			property! :message, String
			property! :mails, Integer
			property! :state, TypeSyncState
		end
	end
end