# Created by Matyáš Pokorný on 2019-06-04.

module ROM
	class PlanningException < ApiException
		def initialize(path)
			super("Failed to plan path '#{path.collect(&:to_s).join(', ')}'!")
		end
	end
end