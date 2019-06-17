# Created by Matyáš Pokorný on 2019-06-04.

module ROM
	module HTTP
		module Filters
			class RangeFilter < HTTPHeaderFilter
				def initialize(itc)
					super(itc, false, :range)
				end
				
				def filter(hdr, value)
					HTTPResponse.new(StatusCode::RANGE_NOT_SATISFIABLE)
				end
			end
		end
	end
end