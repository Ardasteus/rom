# Created by Matyáš Pokorný on 2019-05-27.

module ROM
	# DB hook of ROM DB
	class RomDbHook < DbHook
		# Instantiates the {ROM::RomDbHook} class
		# @param [ROM::Interconnect] itc Registering interconnect
		def initialize(itc)
			super(itc, 'romdb', DB::RomDbContext)
		end
	end
end