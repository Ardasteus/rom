# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class Attachment < Model
		property :id, Integer
		property! :name, String
		property! :type, String
		property! :size, Integer
		property! :mail, Mail
	end
end