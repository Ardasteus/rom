# Created by Matyáš Pokorný on 2019-06-17.

module ROM
	module DB
		# Enum table of mail states
		class TypeStates < Model
			include DbSeed
			
			property :enum, Integer, KeyAttribute[], AutoAttribute[]
			property! :moniker, String, IndexAttribute[]
			property :description, String
			
			seed do
				add(
					TypeStates.new(:moniker => 'inbound', :description => 'Inbound mail, read-only'),
					TypeStates.new(:moniker => 'draft', :description => 'Editable mail, not sent yet'),
					TypeStates.new(:moniker => 'outbound', :description => 'Outbound mail, read-only, not sent yet')
				)
			end
		end
	end
end