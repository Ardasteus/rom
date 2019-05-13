module ROM
	class DbServer < Service
		def initialize
			super('Database server', 'Provides connection to DB')
		end

		def up
			dvr = @itc.fetch(MySqlDriver)
			schema = DbSchema.new
			user = schema.table('user')
			user.column('id', dvr.type(:id))
			user.column('name', dvr.type(:string))
		end

		def down
		end
	end
end