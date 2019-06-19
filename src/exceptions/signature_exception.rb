# Created by Matyáš Pokorný on 2019-06-04.

module ROM
	class SignatureException < ApiException
		def initialize(sig, args)
			super("Signature #(#{sig}) not satisfied!")
		end
	end
end