# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class ChannelContact < Model
		property! :channel, Channel, KeyAttribute[]
		property! :contact, Contact, KeyAttribute[]
	end
end