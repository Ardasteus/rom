module ROM
	class DbServer < Service
		def initialize(itc)
			super(itc, 'Database server', 'Provides connection to DB')
		end

		def up
			dvr = @itc.fetch(Sqlite::SqliteDriver)
			dvr.create(MyContext, Db.new, SchemaBuilder.new(dvr).build(MyContext))
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

			convention(:tab) { |tab| tab.downcase }
			convention(:pk_column) { |tab, col| "pk#{col.downcase}" }
			convention(:fk_column) { |src, tgt, dest, sfx| "fk#{tgt.downcase}#{(sfx == '' ? '' : "_#{sfx.downcase}")}" }
		end
	end
end