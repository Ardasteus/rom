# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class TypeDriver < Model
		include DbSeed

		property :enum, Integer, 0, KeyAttribute[], AutoAttribute[]
		property! :moniker, String, IndexAttribute[]
		property :description, String

		seed do
			add(
				TypeDriver.new(:moniker => 'local', :description => 'Local DB authentication via HASH'),
				TypeDriver.new(:moniker => 'ldap', :description => 'LDAP authentication')
			)
		end
	end
end