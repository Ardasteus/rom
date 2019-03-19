module ROM
	VERSION = '0.1.0'
	
	class Importer
		FILE_OPT  = {
			:want => []
		}
		GROUP_OPT = {
			:want => []
		}
		BENCHMARK = true
		
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
		
		def from(*dir)
			ctx  = @ctx
			@ctx = path(*dir)
			yield
		ensure
			@ctx = ctx
		end
		
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
		
		def all(glob, **opt)
			files(*(Dir[path(glob)].collect { |i| i[@ctx.length..i.length - 1] }), opt)
		end
		
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
		
		class Task
			def name
				@name
			end
			
			def dependencies
				@want
			end
			
			def imported?
				@got
			end
			
			def initialize(nm, want)
				@name = nm
				@want = want
				@got  = false
				@ran  = false
			end
			
			def import
				return if @got
				raise('Circular dependence detected!') if @ran
				@ran = true
				
				@want.select { |i| not i.imported? }.each(&:import)
				run
				
				@got = true
			end
			
			def run
				raise('Method not implemented!')
			end
			
			protected :run
		end
		
		class TaskRequire < Task
			def initialize(req, want)
				super(req, want)
				@req = req
			end
			
			def run
				STDOUT.write "Importing '#{@req}'... " if BENCHMARK
				t = Time.now
				require @req
				puts "#{(Time.now - t).round(2)} s" if BENCHMARK
			end
		end
		
		class TaskGroup < Task
			def initialize(nm)
				super(nm, [])
			end
			
			def run
			end
			
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

ROM::Application.new('.')