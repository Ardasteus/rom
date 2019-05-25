# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class MailTag < Model
		property! :mail, Mail, KeyAttribute[]
		property! :tag, Tag, KeyAttribute[]
	end
end