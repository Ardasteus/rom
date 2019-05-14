module ROM
	class DbServer < Service
		def initialize(itc)
			super(itc, 'Database server', 'Provides connection to DB')
		end

		def up
			dvr = @itc.fetch(Sqlite::SqliteDriver)
			sch = SchemaBuilder.new(dvr).build(MyContext)
			sch.tables.each do |tab|
				qry = dvr.query(:table, Db.new, tab)
				puts qry.query
			end

			sch.tables.each do |tab|
				
			end
		end

		def down
		end

		class Db
			def name; 'sqlite'; end
		end

		class User < Model
			property! :id, Integer
			property! :login, String
		end

		class Account < Model
			property! :id, Integer
			property! :user, User
		end

		class MyContext < DbContext
			table :users, User
			table :accounts, Account
		end
	end
end