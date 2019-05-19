# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class RomDbContext < DbContext
		
		
		convention(:table) do |tab|
			nm = tab.downcase
			
			if nm[nm.length - 2..nm.length - 1] == 'es'
				nm[0..nm.length - 3]
			elsif nm[nm.length - 1] == 's'
				nm[0..nm.length - 2]
			else
				nm
			end
		end
		convention(:pk_column) { |tab, col| "pk#{col.downcase}" }
		convention(:fk_column) do |src, tgt, dest, sfx|
			pfx = (tgt.length > 4 and tgt[0..4] == 'type') ? 'tk' : 'fk'
			"#{pfx}#{tgt.downcase}#{(sfx == '' ? '' : "_#{sfx.downcase}")}"
		end
	end
end