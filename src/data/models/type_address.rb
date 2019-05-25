# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	class TypeAddress < Model
		include DbSeed
		
		property :enum, Integer, KeyAttribute[], AutoAttribute[]
		property! :moniker, String, IndexAttribute[]
		property :description, String
		
		seed do
			add(
				TypeAddress.new(:moniker => 'personal', :description => 'Address used for personal chat'),
				TypeAddress.new(:moniker => 'school', :description => 'Address issued by school'),
				TypeAddress.new(:moniker => 'work', :description => 'Address issued by an employer'),
				TypeAddress.new(:moniker => 'custom', :description => 'Custom address')
			)
		end
	end
end