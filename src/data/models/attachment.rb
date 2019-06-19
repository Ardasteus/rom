# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# Mail attachment
		class Attachment < Model
			property :id, Integer
			property! :name, String
			property! :type, String
			property! :size, Integer
			property! :mail, Mail
			property :file, String
		end
	end
end