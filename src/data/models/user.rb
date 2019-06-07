module ROM
	module DB
		# User
		class User < Model
			property :id, Integer
			property! :login, String
			property! :collection, Collection
			property! :contact, Contact
			property :super, Integer, 0, LengthAttribute[1]
			
			def self.create(db, login, fn, ln, sa = false)
				root = db.collections << DB::Collection.new(:name => '/')
				contact = db.contacts << DB::Contact.new(:first_name => fn, :last_name => ln)
				user = db.users << DB::User.new(:login => login, :collection => root, :contact => contact, :super => sa ? 1 : 0)
				%w(inbox sent spam trash).each do |folder|
					db.collections << DB::Collection.new(:name => folder, :collection => root)
				end
				
				user
			end
		end
	end
end