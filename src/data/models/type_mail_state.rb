# Created by Matyáš Pokorný on 2019-06-17.

module ROM
	module DB
		# Enum table of mail states
		class TypeMailState < Model
			include DbSeed
			
			INBOUND = 'inbound'
			DRAFT = 'draft'
			OUTBOUND = 'outbound'
			
			property :enum, Integer, KeyAttribute[], AutoAttribute[]
			property! :moniker, String, IndexAttribute[]
			property :description, String
			
			seed do
				add(
					TypeMailState.new(:moniker => INBOUND, :description => 'Inbound mail, read-only'),
					TypeMailState.new(:moniker => DRAFT, :description => 'Editable mail, not sent yet'),
					TypeMailState.new(:moniker => OUTBOUND, :description => 'Outbound mail, read-only, not sent yet')
				)
			end
		end
	end
end