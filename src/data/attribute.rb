# Created by Matyáš Pokorný on 2019-03-24.

module ROM
	# Defines a metadata class of the model system
	class Attribute
		# Instantiates the attribute
		# @param [Array<String>] args Arguments to initialize the class with
		# @return [ROM::Attribute] Instance of attribute
		def self.[](*args)
			return self.new(*args)
		end
	end
end