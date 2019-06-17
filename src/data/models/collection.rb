module ROM
	module DB
		# Mailbox folder
		class Collection < Model
			property :id, Integer
			property! :name, String, IndexAttribute[]
			property :collection, Collection, SuffixAttribute['parent']
			property :flags, Integer, 0
			
			def full_path
				path = "/#{name}"
				col = collection
				until col.name == '/'
					path = "/#{col.name}#{path}"
					col = col.collection
				end
				
				path
			end
			
			def find(db, path)
				ret = self
				path.split('/').each do |part|
					ret = db.collections.find { |i| (i.collection == ret).and(i.name == part)}
					break if ret == nil
				end
				
				ret
			end
		end
	end
end