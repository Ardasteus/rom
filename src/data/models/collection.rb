module ROM
	module DB
		# Mailbox folder
		class Collection < Model
			property :id, Integer
			property! :name, String, IndexAttribute[]
			property :collection, Collection, SuffixAttribute['parent']
			property :flags, Integer, 0
		end
	end
end