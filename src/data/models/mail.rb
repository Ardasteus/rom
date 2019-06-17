# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# A stored mail footprint
		class Mail < Model
			property :id, Integer
			property! :subject, String, IndexAttribute[]
			property :identifier, String, IndexAttribute[]
			property! :date, Integer
			property! :excerpt, String
			property! :sender, Participant, SuffixAttribute['sender']
			property! :state, TypeStates
			property :reply_address, String
			property! :mailbox, Mailbox
			property :references, Integer, 1
			property! :is_local, Integer, LengthAttribute[1]
			property! :is_read, Integer, LengthAttribute[1]
		end
	end
end