module ROM
	class DbContext < Service
		def initialize(itc)
			super(itc)
		end

		# Prepares the model class
		# @return [void]
		def self.prepare_model
			@props = {}
		end
		
		# Prepares all subclasses
		# @param [Class] sub Type of subclass
		# @return [void]
		def self.inherited(sub)
			sub.prepare_model
		end
	end
end