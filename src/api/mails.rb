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
				
				action :fetch, DataPage, AuthorizeAttribute[] do
					ret = []
					@db.collections.select { |i| i.collection == @col }.each do |col|
						ret << CollectionModel.new(:name => col.name, :flags => [])
					end
					
					DataPage.new(:items => ret, :total => ret.length)
				end
				
				action :navigate, CollectionResource, AuthorizeAttribute[], DefaultAction[] do |name|
					col = @db.collections.find { |i| (i.collection == @col).and(i.name == name) }
					raise(NotFoundException.new("#{@path}/#{name}")) if col == nil
					
					CollectionResource.new(@db, col, "#{@path}/#{name}")
				end
				
				def close
					@db.close
				end
			end
			
			action :fetch, DataPage, AuthorizeAttribute[] do
				db = interconnect.fetch(DbServer).open(DB::RomDbContext)
				CollectionResource.new(db, db.protect { db.users.find(identity.id).collection }, '/').fetch
			end
			
			action :navigate, CollectionResource, AuthorizeAttribute[], DefaultAction[] do |name|
				db = interconnect.fetch(DbServer).open(DB::RomDbContext)
				col = nil
				db.protect do
					root = db.users.find(identity.id).collection
					col = db.collections.find { |i| (i.collection == root).and(i.name == name) }
					raise(NotFoundException.new("/#{name}")) if col == nil
				end
				
				CollectionResource.new(db, col, "/#{name}")
			end
		end
	end
end