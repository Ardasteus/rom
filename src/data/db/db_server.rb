module ROM
	# Manages DBs
	class DbServer < Service
		# Instantiates the {ROM::DbServer} class
		# @param [ROM::Interconnect] itc Registering interconnect
		def initialize(itc)
			super(itc, 'Database server', 'Provides connection to DBs', Filesystem)
			@dbs = {}
			@cons = []
		end
		
		# Called to start the service
		def up
			cfg = @itc.fetch(DbConfig)
			log = @itc.fetch(LogServer)
			
			cfg.dbs.each_pair do |name, db|
				log.trace("Preparing DB '#{name}'...")
				hook = @itc.fetch(DbHook) { |i| i.name == name }
				raise("DB hook for '#{name}' not found!") if hook == nil
				
				dvr = @itc.fetch(DbDriver) { |i| i.name == db.driver }
				raise("DB driver '#{db.driver}' not found!") if dvr == nil
				
				log.trace("Building DB schema of '#{hook.context.name}' for '#{name}'...")
				sch = SchemaBuilder.new(dvr).build(hook.context)
				
				log.trace("Connecting to '#{name}' via '#{dvr.name}'...")
				conf = dvr.config_model.from_object(db.connection)
				@dbs[hook.context] = { :schema => sch, :driver => dvr, :config => conf }
				con = dvr.connect(conf)
				
				log.trace("Creating structure of DB '#{name}'...")
				stat = dvr.create(con, sch)
				
				log.trace("Opening DB '#{name}' as '#{hook.context.name}'...")
				con.select_db
				ctx = hook.context.new(con, sch)
				
				log.trace("Seeding DB '#{name}'...")
				ctx.seed_context(stat)
				
				con.close
			end
		end
		
		# Stops the service
		def down
			log = @itc.fetch(LogServer)
			log.trace('Closing open DB connections...')
			@cons.each(&:close)
		end
		
		# Gets a DB context
		# @param [Class] ctx DB context class to create
		# @return [ROM::DbContext] Requested DB context
		def [](ctx)
			return nil unless @dbs.has_key?(ctx)
			db = @dbs[ctx]
			con = db[:driver].connect(db[:config])
			con.select_db
			ret = ctx.new(con, db[:schema])
			if block_given?
				begin
					yield(ret)
				rescue Exception => ex
					raise
				ensure
					con.close
				end
			else
				@cons << con
				
				ret
			end
		end
		
		alias open []
	end
end