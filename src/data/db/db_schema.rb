# Created by Matyáš Pokorný on 2019-05-12.

module ROM
	class DbSchema
		def tables
			@tab
		end

		def initialize
			@tab = []
		end

		def table(nm)
			raise("Table with name '#{nm}' was already added!") if @tab.any? { |i| i.name == nm }
			tab = DbTable.new(nm)
			@tab << tab

			tab
		end
	end
end