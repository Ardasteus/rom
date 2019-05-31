# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# N:M mapping between mails and participants
		class MailParticipant < Model
			property! :mail, Mail, KeyAttribute[]
			property! :participant, Participant, KeyAttribute[]
		end
	end
end