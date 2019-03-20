module ROM
	# Version of the application
	VERSION = '0.1.0'
	
	# Imports scripts and resolves dependencies
	class Importer
		# Default options of the {#files} function
		FILE_OPT  = {
			:want => []
		}
		# Default options of the {#group} function
		GROUP_OPT = {
			:want => []
		}
		# Indicates whether benchmarking should be enabled
		BENCHMARK = true
		
		# Instantiates the {ROM::Importer} class
		# @param [String] root Location of the source files
		# @yield [] Block of the importer
		def initialize(root, &block)
			@root  = root
			@graph = TaskGroup.new('root')
			@tasks = {}
			@group = false
			@ctx   = root
			instance_eval(&block) if block != nil
			t = Time.now
			@graph.import
			puts "Imported in #{(Time.now - t).round(2)}!" if BENCHMARK
		end
		
		# Enters a directory context
		# @param [Array<String>] dir Directory to enter
		# @return [void]
		def from(*dir)
			ctx  = @ctx
			@ctx = path(*dir)
			yield
		ensure
			@ctx = ctx
		end
		
		# Groups imports together
		# @param [Symbol, String] grp Name of group
		# @param [Hash] opt Options of the group
		# @option opt [String, Symbol, Array<[String, Symbol]>] :want Dependencies to import first
		# @return [void]
		def group(grp, **opt)
			raise('Groups cannot nest!') if @group
			
			o = GROUP_OPT.clone
			opt.each_pair do |k, v|
				raise("Unknown option #{k.inspect}!") unless o.has_key?(k)
				o[k] = v
			end
			
			o[:want] = *o[:want] unless o[:want].is_a?(Array)
			
			@group = true
			g      = @graph
			@graph = TaskGroup.new(grp.to_s)
			o[:want].each { |i| @graph << dep(i) }
			begin
				yield
			ensure
				@group = false
				g << @graph
				@tasks[grp.to_sym] = @graph
				@graph             = g
			end
		end
		
		# Imports files
		# @param [Array<String>] files Files to import
		# @param [Hash] opt Options of the files
		# @option opt [String, Symbol, Array<[String, Symbol]>] :want Dependencies to import first
		# @return [void]
		def files(*files, **opt)
			o = FILE_OPT.clone
			opt.each_pair do |k, v|
				raise("Unknown option #{k.inspect}!") unless o.has_key?(k)
				o[k] = v
			end
			
			o[:want] = *o[:want] unless o[:want].is_a?(Array)
			
			files.collect { |i| path(File.extname(i) == '' ? "#{i}.rb" : i) }.each do |i|
				raise("File '#{i}' already added!") if @tasks.has_key?(i)
				raise("File '#{i}' not found!") unless File.exist?(i)
				task(i, TaskRequire.new(i, o[:want].collect(&method(:dep))))
			end
		end
		
		# Globs a directory and imports all matched files
		# @param [String] glob GLOB pattern to use
		# @param [Hash] opt Options of the files
		# @options opt [String, Symbol, Array<[String, Symbol]>] :want Dependencies to imports first
		# @return [void]
		def all(glob, **opt)
			files(*(Dir[path(glob)].collect { |i| i[@ctx.length..i.length - 1] }), opt)
		end
		
		# Imports gems
		# @param [Array<String>] gem Gems to import
		# @return [void]
		def gems(*gem)
			gem.each do |i|
				raise("Gem '#{i}' already added!") if @tasks.has_key?(i)
				task(i, TaskRequire.new(i, []))
			end
		end
		
		def task(k, t)
			@graph << t
			@tasks[k] = t
		end
		
		def path(*parts)
			File.join(@ctx, *parts)
		end
		
		def dep(d)
			@tasks[d]
		end
		
		private :path, :task, :dep
		
		# Represents an import task
		class Task
			# Gets the name of the task
			# @return [String] Name of the task
			def name
				@name
			end
			
			# Gets the dependencies of the task
			# @return [Array<String>] Dependencies of the task
			def dependencies
				@want
			end
			
			# Checks whether the task was already run
			# @return [Bool] True if the task ran; false otherwise
			def imported?
				@got
			end
			
			# Instantiates the {ROM::Importer::Task} class
			# @param [String] nm Name of the task
			# @param [Array<Task>] want Dependencies of the task
			def initialize(nm, want)
				@name = nm
				@want = want
				@got  = false
				@ran  = false
			end
			
			# Runs the import task
			# @return [void]
			def import
				return if @got
				raise('Circular dependence detected!') if @ran
				@ran = true
				
				@want.select { |i| not i.imported? }.each(&:import)
				run
				
				@got = true
			end
			
			# Method of the task
			# @return [void]
			def run
				raise('Method not implemented!')
			end
			
			protected :run
		end
		
		# Task which requires a script/gem
		class TaskRequire < Task
			# Instantiates the {ROM::Importer::TaskRequire} class
			# @param [String] req Path to require
			# @param [Array<Task>] want Dependencies of the task
			def initialize(req, want)
				super("file '#{req}'", want)
				@req = req
			end
			
			# Requires the file
			# @return [void]
			def run
				STDOUT.write "Importing '#{@req}'... " if BENCHMARK
				t = Time.now
				require @req
				puts "#{(Time.now - t).round(2)} s" if BENCHMARK
			end
		end
		
		# Task which groups other tasks together as one
		class TaskGroup < Task
			# Instantiates the {ROM::Importer::TaskGroup} class
			# @param [String] nm Name of the group
			def initialize(nm)
				super("group '#{nm}'", [])
			end
			
			# Group task does nothing
			# @return [void]
			def run
			end
			
			# Adds a dependency
			# @param [Task] item Item to add as a dependency
			# @return [void]
			def <<(item)
				dependencies << item
			end
		end
	end
	
	Importer.new($includes == nil ? File.dirname(__FILE__) : $includes) do
		group :gems do
			gems 'json', 'safe_yaml', 'mysql2', 'set'
		end
		
		group :core, :want => :gems do
			from 'diagnostics' do
				files 'logger', 'short_formatter', 'text_logger'
			end
			
			from 'dynamic' do
				files 'component', 'interconnect'
			end

			from 'jobs' do
			  files 'job', 'job_pool', 'job_server'
			end
		end
		
		group :app, :want => :core do
			files 'application'
		end
	end
end