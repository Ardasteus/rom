# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class Mail < Model
		property :id, Integer
		property! :subject, String, IndexAttribute[]
		property! :identifier, String, IndexAttribute[]
		property! :date, Time
		property! :excerpt, String
		property! :sender, Participant, SuffixAttribute['sender']
		property :reply_address, String
		property! :mailbox, Mailbox
		property :references, Integer, 1
		property! :is_local, Types::Boolean
		property! :is_read, Types::Boolean
	end
end