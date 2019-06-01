# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# N:M mapping table between chat channels and contacts
		class ChannelContact < Model
			property! :channel, Channel, KeyAttribute[]
			property! :contact, Contact, KeyAttribute[]
		end
	end
end