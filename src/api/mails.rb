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
				
				class UpdateModel < Model
					property! :path, String
				end
				
				def initialize(db, root, col, path)
					@db = db
					@root = root
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
				
				action :update, Types::Void, AuthorizeAttribute[],
					:body! => UpdateModel do |body|
					raise(ArgumentException.new('path', 'Invalid path!')) unless body.path =~ ApiConstants::RGX_PATH
					raise(NotFoundException.new('Collection not found!')) unless @col.is_a?(Entity)
					lag = nil
					dest = @root
					parts = body.path[1..body.path.length].split('/')
					parts.each do |part|
						raise(NotFoundException.new('Path not found!')) if dest == nil
						lag = dest
						dest = @db.collections.find { |i| (i.collection == dest).and(i.name == part) }
					end
					if dest == nil
						@col.name = parts.last
						@col.collection = lag
					else
						raise(InvalidOperationException.new('Name already taken!')) if @db.collections.any? { |i| (i.collection == dest).and(i.name == @col.name) }
						@col.collection = dest
					end
				
					@db.collections.update(@col)
				end
				
				action :delete, Types::Void, AuthorizeAttribute[] do
					raise(InvalidOperationException.new('Collection is root!')) if @path == ''
					raise(NotFoundException.new('Collection not found!')) unless @col.is_a?(Entity)
					
					@db.maps.delete { |i| i.collection == @col }
					@db.collection_mails.select { |i| i.collection == @col }.each do |join|
						join.mail.references -= 1
						@db.mails.update(join.mail)
					end
					@db.collection_mails.delete { |i| i.collection == @col }
					@db.collections.select { |i| i.collection == @col }.each do |child|
						CollectionResource.new(@db, @root, child, '_').delete
					end
					@db.collections.delete(@col)
				end
				
				action :navigate, CollectionResource, AuthorizeAttribute[], DefaultAction[] do |name|
					raise(NotFoundException.new('Collection not found!')) unless @col.is_a?(Entity)
					
					col = nil
					if @col.is_a?(Entity)
						col = @db.collections.find { |i| (i.collection == @col).and(i.name == name) }
						col = DB::Collection.new(:name => name, :collection => @col) if col == nil
					else
						raise(NotFoundException.new("#{@path}/#{name}"))
					end
					
					CollectionResource.new(@db, @root, col, "#{@path}/#{name}")
				end
				
				def close(tail)
					@db.close if tail
				end
			end
			
			def self.get_root(itc, id)
				db = itc.fetch(DbServer).open(DB::RomDbContext)
				root = db.protect { db.users.find(id.id).collection }
				CollectionResource.new(db, root, root, '')
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