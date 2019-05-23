# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	class RomDbContext < DbContext
		table :typedriver, TypeDriver
		table :user, User
		table :collection, Collection
		table :contact, Contact
		table :login, Login
		
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
			if tgt.length > 4 and tgt[0..3] == 'type'
				"tk#{tgt[4..tgt.length - 1].downcase}#{(sfx == '' ? '' : "_#{sfx.downcase}")}"
			else
				"fk#{tgt.downcase}#{(sfx == '' ? '' : "_#{sfx.downcase}")}"
			end
		end
	end
end