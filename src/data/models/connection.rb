# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# Internet service connection configuration
		class Connection < Model
			property :id, Integer
			property! :host, String
			property! :port, Integer
			property! :user, String
			property :password, String
			property :protection, TypeProtection
		end
	end
end