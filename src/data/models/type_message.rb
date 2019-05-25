# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class TypeMessage < Model
		include DbSeed
		
		property :enum, Integer, KeyAttribute[], AutoAttribute[]
		property! :moniker, String, IndexAttribute[]
		property :description, String
		
		seed do
			add(
				TypeMessage.new(:moniker => 'normal', :description => 'Message without context'),
				TypeMessage.new(:moniker => 'reply', :description => 'Message in response to other message'),
				TypeMessage.new(:moniker => 'forward', :description => 'Forwarded message')
			)
		end
	end
end