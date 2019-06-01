# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# Enum table of message media types
		class TypeMedia < Model
			include DbSeed
			
			property :enum, Integer, KeyAttribute[], AutoAttribute[]
			property! :moniker, String, IndexAttribute[]
			property :description, String
			
			seed do
				add(
					TypeMedia.new(:moniker => 'picture', :description => 'Any image file (JPEG, PNG, BMP)'),
					TypeMedia.new(:moniker => 'audio', :description => 'Any audio file (MP3, OGG)'),
					TypeMedia.new(:moniker => 'file', :description => 'Any file')
					)
			end
		end
	end
end