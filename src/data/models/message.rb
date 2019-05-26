# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class Message < Model
		property :id, Integer
		property! :sender, Contact, SuffixAttribute['sender']
		property! :message, String
		property! :timestamp, Integer
		property :parent, Message, SuffixAttribute['parent']
		property! :type, TypeMessage
		property! :channel, Channel
		property :references, Integer, 1
		property :media, Media
	end
end