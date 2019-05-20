module ROM
	class DbServer < Service
		def initialize(itc)
			super(itc, 'Database server', 'Provides connection to DB')
		end
		
		def up
			dvr = @itc.fetch(Sqlite::SqliteDriver)
			conf = { :file => @itc.fetch(Filesystem).temp('romdb.sqlite.db').to_s }
			sch = SchemaBuilder.new(dvr).build(MyContext)
			db = dvr.connect(dvr.config_model.from_object(conf))
			dvr.create(db, sch)
			tab = sch[:user]
			qry = dvr.select(tab, tab.double.login == 'this', [Queries::Order.new(tab.double.login, :desc)], { :p1 => tab.double.login + '...' }, 2, 5)
			db.execute(qry)
			puts "<#{qry.query}> #{qry.arguments.inspect}"
		end
		
		def down
		end
		
		class User < Model
			property! :id, Integer
			property! :login, String, IndexAttribute[true]
		end
		
		class Account < Model
			property! :id, Integer
			property! :user, User, SuffixAttribute['my']
		end
		
		class MyContext < DbContext
			table :users, User
			table :accounts, Account
			
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
			convention(:fk_column) { |src, tgt, dest, sfx| "fk#{tgt.downcase}#{(sfx == '' ? '' : "_#{sfx.downcase}")}" }
		end
	end
end