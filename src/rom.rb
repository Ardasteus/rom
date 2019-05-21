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
		def initialize(root, dyn = true, &block)
			@root = root
			@ctx = root
			@files = []
			t = Time.new
			instance_eval(&block) if block != nil
			load_all unless dyn
			puts "Ready in #{(Time.now - t).round(2)}s!" if BENCHMARK
		end
		
		# Creates a class to file mapping
		# @param [String] file Path to file
		# @param [String] klass Classes to be mapped
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
				# puts "Linking #{k} to '#{path(file)}'..."
				f = path(file)
				mod.autoload(kl.to_sym, f)
				@files << f unless @files.include?(f)
			end
		end
		
		# Globs a directory and imports all matched files
		# @param [String] glob GLOB pattern to use
		def all(glob)
			Dir[path(glob)].collect { |i| i[0..i.length - 1] }.each(&method(:require))
		end
		
		# Imports gems
		# @param [String] gem Gems to import
		# @return [void]
		def gems(*gem)
			gem.each(&method(:require))
		end
		
		def path(*parts)
			File.join(@ctx, *parts)
		end
		
		# Loads all files statically
		def load_all
			puts 'Loading ROM statically...'
			@files.each do |f|
				STDOUT.write "Loading '#{f}'..." if BENCHMARK
				t = Time.new
				require(f)
				puts " #{(Time.now - t).round(2)}s" if BENCHMARK
			end
		end
		
		private :path
	end
	
	# noinspection RubyStringKeysInHashInspection, RubyLiteralArrayInspection
	
	# File to class map of the application
	MAP = {
		'data' => {
			'db' => {
				'mysql' => {
					'mysql_driver' => 'ROM::MySql::MySqlDriver'
				},
				'sqlite' => {
					'sqlite_driver' => 'ROM::Sqlite::SqliteDriver'
				},
				'queries' => {
					'query' => 'ROM::Queries::Query',
					'query_expression' => 'ROM::Queries::QueryExpression',
					'column_value' => 'ROM::Queries::ColumnValue',
					'binary_operator' => 'ROM::Queries::BinaryOperator',
					'function_expression' => 'ROM::Queries::FunctionExpression',
					'unary_operator' => 'ROM::Queries::UnaryOperator',
					'constant_value' => 'ROM::Queries::ConstantValue',
					'order' => 'ROM::Queries::Order'
				},
				'db_column' => 'ROM::DbColumn',
				'db_driver' => 'ROM::DbDriver',
				'db_index' => 'ROM::DbIndex',
				'db_reference' => 'ROM::DbReference',
				'db_schema' => 'ROM::DbSchema',
				'db_table' => 'ROM::DbTable',
				'db_type' => 'ROM::DbType',
				'db_server' => 'ROM::DbServer',
				'db_context' => 'ROM::DbContext',
				'db_results' => 'ROM::DbResults',
				'db_key' => 'ROM::DbKey',
				'db_collection' => 'ROM::DbCollection',
				'entity' => 'ROM::Entity',
				'entity_mapper' => 'ROM::EntityMapper',
				'lazy_promise' => 'ROM::LazyPromise',
				'lazy_loader' => 'ROM::LazyLoader',
				'schema_builder' => 'ROM::SchemaBuilder',
				'key_attribute' => 'ROM::KeyAttribute',
				'reference_attribute' => 'ROM::ReferenceAttribute',
				'suffix_attribute' => 'ROM::SuffixAttribute',
				'index_attribute' => 'ROM::IndexAttribute',
				'auto_attribute' => 'ROM::AutoAttribute',
				'sql_query' => 'ROM::SqlQuery',
				'sql_driver' => 'ROM::SqlDriver',
				'db_connection' => 'ROM::DbConnection'
			},
			'rom_db_context' => 'ROM::RomDbContext',
			'attribute' => 'ROM::Attribute',
			'model' => ['ROM::Model', 'ROM::ModelProperty'],
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
			'buffer_logger' => 'ROM::BufferLogger',
			'log_server' => 'ROM::LogServer',
			'logger' => 'ROM::Logger',
			'short_formatter' => 'ROM::ShortFormatter',
			'text_logger' => 'ROM::TextLogger'
		},
		'dynamic' => {
			'api_context' => 'ROM::ApiContext',
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
				'http_job_pool' => 'ROM::HTTP::HTTPJobPool',
				'http_listener_job' => 'ROM::HTTP::HTTPListenerJob',
				'http_respond_job' => 'ROM::HTTP::HTTPRespondJob'
			},
			'http_method_handlers' => {
				'delete_method' => 'ROM::HTTP::Methods::DeleteMethod',
				'get_method' => 'ROM::HTTP::Methods::GetMethod',
				'http_method' => 'ROM::HTTP::Methods::HTTPMethod',
				'post_method' => 'ROM::HTTP::Methods::PostMethod',
				'put_method' => 'ROM::HTTP::Methods::PutMethod'
			},
			'http_config' => 'ROM::HTTP::HTTPConfig',
			'http_content' => 'ROM::HTTP::HTTPContent',
			'http_request' => 'ROM::HTTP::HTTPRequest',
			'http_response' => 'ROM::HTTP::HTTPResponse',
			'http_service' => 'ROM::HTTP::HTTPService',
			'httpapi_resolver' => 'ROM::HTTP::HTTPAPIResolver',
			'object_content' => 'ROM::HTTP::ObjectContent',
			'status_code' => 'ROM::HTTP::StatusCode',
			'security' => 'ROM::HTTP::Security'
		},
		'jobs' => {
			'job' => 'ROM::Job',
			'job_pool' => 'ROM::JobPool',
			'job_server' => 'ROM::JobServer'
		},
		'serializers' => {
			'json_serializer' => 'ROM::DataSerializers::JSONSerializer',
			'serializer' => 'ROM::DataSerializers::Serializer'
		},
		'application' => 'ROM::Application',
		'filesystem' => 'ROM::Filesystem'
	}
	
	Importer.new($includes == nil ? File.dirname(__FILE__) : $includes, ($ROM_DYNAMIC == nil or $ROM_DYNAMIC)) do
		gems 'json', 'safe_yaml', 'set', 'socket', 'openssl', 'pathname', 'sqlite3'
		
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
		all 'data/models/**/*.rb'
	end
end
