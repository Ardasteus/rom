# Created by Matyáš Pokorný on 2019-06-20.

module ROM
	module DB
		# Enum table of synchronization states
		class TypeSyncState < Model
			include DbSeed
			
			SUCCESS = 'success'
			PARTIAL = 'partial'
			FAILURE = 'failure'
			
			property :enum, Integer, KeyAttribute[], AutoAttribute[]
			property! :moniker, String, IndexAttribute[]
			property :description, String
			
			seed do
				add(
					TypeSyncState.new(:moniker => SUCCESS, :description => 'All mails transferred successfully'),
					TypeSyncState.new(:moniker => PARTIAL, :description => 'Some mails were transferred, but some failed to do so'),
					TypeSyncState.new(:moniker => FAILURE, :description => 'No mails could be transferred')
				)
			end
		end
	end
end