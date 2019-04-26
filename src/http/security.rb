# Created by Matyáš Pokorný on 2019-04-26.

module ROM
	module HTTP
		# Represents an SSL security context
		# @attr [OpenSSL::X509::Certificate] cert Signed certificate
		# @attr [OpenSSL::PKey::RSA] key Encryption key
		Security = Struct.new(:cert, :key, :keyword_init => true)
	end
end