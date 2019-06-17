# Created by Matyáš Pokorný on 2019-06-16.

module ROM
	class ApiConstants
		RGX_ADDRESS = /^(?'local'[!#$%&'*+\-\/=?^_`{|}~A-Z0-9][!#$%&'*+\-\/=?^_`{|}~A-Z0-9.]{0,63}(?<=[!#$%&'*+\-\/=?^_`{|}~A-Z0-9])|"[^"]+")@(?'host'[A-Z0-9][A-Z0-9\-.]{0,62}(?<=[A-Z0-9]))$/mi
		RGX_PATH = /^(\/|(\/[a-z0-9 _.\-]+)+)$/mi
	end
end