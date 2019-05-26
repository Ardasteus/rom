module ROM
	class DbServer < Service
		def initialize(itc)
			super(itc, 'Database server', 'Provides connection to DBs', Filesystem)
		end
		
		def up
			dvr = @itc.fetch(Sqlite::SqliteDriver)
			
			conf = { :file => @itc.fetch(Filesystem).path('romdb.sqlite.db').to_s }
			sch = SchemaBuilder.new(dvr).build(RomDbContext)
			db = dvr.connect(dvr.config_model.from_object(conf))
			stat = dvr.create(db, sch)
			
			ctx = RomDbContext.new(db, sch)
			ctx.seed_context(stat)
			
			root = ctx.collections << Collection.new(:name => '/')
			joe_contact = ctx.contacts << Contact.new(:first_name => 'Joe', :last_name => 'Generic')
			joe_user = ctx.users << User.new(:login => 'jgeneric', :first_name => 'Joe', :last_name => 'Generic', :collection => root, :contact => joe_contact)
			ctx.logins << Login.new(:driver => ctx.driver_types.find(1), :token => '', :user => joe_user, :last_logon => Time.now.to_i)
		end
		
		def down
		end
	end
end