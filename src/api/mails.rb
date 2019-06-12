# Created by Matyáš Pokorný on 2019-06-12.

module ROM
	module API
		class MailsController < StaticResource
			namespace :api, :v1, :mails
			
			class CollectionResource < Resource
				class CollectionModel < Model
					property! :name, String
					property! :flags, Types::Array[String]
				end
				
				def initialize(db, col, path)
					@db = db
					@col = col
					@path = path
				end
				
				def name?
					@col.name =~ /^[a-z0-9 _.\-]+$/i
				end
				
				action :fetch, DataPage, AuthorizeAttribute[] do
					raise(NotFoundException.new(@path)) unless @col.is_a?(Entity)
					
					ret = []
					@db.collections.select { |i| i.collection == @col }.each do |col|
						ret << CollectionModel.new(:name => col.name, :flags => [])
					end
					
					DataPage.new(:items => ret, :total => ret.length)
				end
				
				action :create, DataPage, AuthorizeAttribute[] do
					raise(InvalidOperationException.new('Collection name collision!')) if @col.is_a?(Entity)
					raise(ArgumentException.new('name', "Invalid collection name!: #{@col.name}")) unless name?
					
					@db.collections << @col
					
					DataPage.new(:items => [], :total => 0)
				end
				
				action :navigate, CollectionResource, AuthorizeAttribute[], DefaultAction[] do |name|
					col = nil
					if @col.is_a?(Entity)
						col = @db.collections.find { |i| (i.collection == @col).and(i.name == name) }
						col = DB::Collection.new(:name => name, :collection => @col) if col == nil
					else
						raise(NotFoundException.new("#{@path}/#{name}"))
					end
					
					CollectionResource.new(@db, col, "#{@path}/#{name}")
				end
				
				def close(tail)
					@db.close if tail
				end
			end
			
			def self.get_root(itc, id)
				db = itc.fetch(DbServer).open(DB::RomDbContext)
				CollectionResource.new(db, db.protect { db.users.find(id.id).collection }, '')
			end
			
			action :fetch, DataPage, AuthorizeAttribute[] do
				MailsController.get_root(interconnect, identity).fetch
			end
			
			action :create, DataPage, AuthorizeAttribute[] do
				raise(InvalidOperationException.new('No collection path specified!'))
			end
			
			action :navigate, CollectionResource, AuthorizeAttribute[], DefaultAction[] do |name|
				MailsController.get_root(interconnect, identity).navigate(name)
			end
		end
	end
end