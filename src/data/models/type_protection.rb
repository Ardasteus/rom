# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# Enum table of connection protection types
		class TypeProtection < Model
			include DbSeed
			
			property :enum, Integer, KeyAttribute[], AutoAttribute[]
			property! :moniker, String, IndexAttribute[]
			property :description, String
			
			seed do
				add(
					TypeProtection.new(:moniker => 'none', :description => 'No channel protection'),
					TypeProtection.new(:moniker => 'tls', :description => 'Channel secured using TLS')
					)
			end
		end
	end
end