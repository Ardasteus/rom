module ROM
	# Version of the application
	VERSION = '0.1.0'
	
	# Imports scripts and resolves dependencies
	class Importer
		# Indicates whether benchmarking should be enabled
		BENCHMARK = true

		# Instantiates the {ROM::Importer} class
		# @param [String] root Location of the source files
		# @yield [] Block of the importer
		def initialize(root, &block)
			@root  = root
			@ctx   = root
			t = Time.new
			instance_eval(&block) if block != nil
			puts "Imported in #{(Time.now - t).round(2)}!" if BENCHMARK
		end
		
		# Imports file
		def file(file, *klass)
			klass.each do |k| 
				mods = k.split('::')
				kl = mods.delete_at(mods.length - 1)
				mod = mods.collect { |m| m.to_sym }.reduce(Object) do |last, m|
					con = (last.constants.include?(m) ? last.const_get(m) : nil)
					if con == nil
						con = Module.new
						last.const_set(m, con)
					end
					next con
				end
				puts "Linking #{k} to '#{path(file)}'..."
				mod.autoload(kl.to_sym, path(file)) 
			end
		end
		
		# Globs a directory and imports all matched files
		# @param [String] glob GLOB pattern to use
		def all(glob)
			Dir[path(glob)].collect { |i| i[0..i.length - 1] }.each(&method(:require))
		end
		
		# Imports gems
		# @param [Array<String>] gem Gems to import
		# @return [void]
		def gems(*gem)
			gem.each(&method(:require))
		end

		def path(*parts)
			File.join(@ctx, *parts)
		end

		private :path
	end
	
	MAP = {
		'data' => {
			'attribute' => 'ROM::Attribute' ,
			'model' => [ 'ROM::Model', 'ROM::ModelProperty' ],
			'types' => [ 
				'ROM::Types::Type',
				'ROM::Types::Just',
				'ROM::Types::Union',
				'ROM::Types::Array',
				'ROM::Types::Hash',
				'ROM::Types::Boolean',
				'ROM::Types::Maybe',
			]
		},
		'diagnostics' => {
			'log_server' => 'ROM::LogServer',
			'logger' => 'ROM::Logger',
			'short_formatter' => 'ROM::ShortFormatter',
			'text_logger' => 'ROM::TextLogger'
		},
		'dynamic' => {
			'api_gateway' => 'ROM::ApiGateway',
			'component' => 'ROM::Component',
			'config' => 'ROM::Config',
			'interconnect' => 'ROM::Interconnect',
			'resource' => [ 
				'ROM::Resource',
				'ROM::StaticResource',
				'ROM::ResourceAction',
				'ROM::ActionSignature',
				'ROM::DefaultAction'
			],
			'service' => 'ROM::Service'
		},
		'http' => {
			'http_jobs' => {
				'http_job_pool' => 'ROM::HTTPJobPool',
				'http_listener_job' => 'ROM::HTTPListenerJob',
				'http_respond_job' => 'ROM::HTTPRespondJob'
			},
			'http_config' => 'ROM::HTTPConfig',
			'http_content' => 'ROM::HTTPContent',
			'http_request' => 'ROM::HTTPRequest',
			'http_response' => 'ROM::HTTPResponse',
			'http_service' => 'ROM::HTTPService',
			'status_code' => 'ROM::StatusCode'
		},
		'jobs' => {
			'job' => 'ROM::Job',
			'job_pool' => 'ROM::JobPool',
			'job_server' => 'ROM::JobServer'
		},
		'application' => 'ROM::Application'
	}

	Importer.new($includes == nil ? File.dirname(__FILE__) : $includes) do
		gems 'json', 'safe_yaml', 'set', 'socket', 'openssl'
		
		def map(m = MAP, path = nil)
			m.each_pair do |k, v|
				pth = path == nil ? k : File.join(path, k)
				if v.is_a?(Hash)
					map(v, pth)
				elsif v.is_a?(Array)
					file(pth, *v)
				else
					file(pth, v)
				end
			end
		end

		map

		all 'api/**/*.rb'
	end
end