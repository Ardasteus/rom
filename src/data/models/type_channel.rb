# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# Enum table of channel types
		class TypeChannel < Model
			include DbSeed
			
			property :enum, Integer, KeyAttribute[], AutoAttribute[]
			property! :moniker, String, IndexAttribute[]
			property :description, String
			
			seed do
				add(
					TypeChannel.new(:moniker => 'direct', :description => 'Direct communication between two parties'),
					TypeChannel.new(:moniker => 'group', :description => 'Shared communication channel between any number of parties')
					)
			end
		end
	end
end