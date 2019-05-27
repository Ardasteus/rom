# Created by Matyáš Pokorný on 2019-05-27.

module ROM
	class RomDbHook < DbHook
		def initialize(itc)
			super(itc, 'romdb', RomDbContext)
		end
	end
end