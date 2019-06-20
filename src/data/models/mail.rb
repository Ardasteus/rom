# Created by Matyáš Pokorný on 2019-05-26.

module ROM
	module DB
		# A stored mail footprint
		class Mail < Model
			property :id, Integer
			property! :subject, String, IndexAttribute[]
			property :identifier, String, IndexAttribute[]
			property! :date, Integer
			property! :excerpt, String
			property! :sender, Participant, SuffixAttribute['sender']
			property! :state, TypeMailState
			property :file, String
			property :size, Integer, 0
			property :reply_address, String
			property! :mailbox, Mailbox
			property :references, Integer, 1
			property! :is_local, Integer, LengthAttribute[1]
			property! :is_read, Integer, LengthAttribute[1]
			
			def local?
				is_local == 1
			end
			
			def read?
				is_read == 1
			end
			
			def read=(val)
				is_read = val ? 1 : 0
			end
			
			def local=(val)
				is_local = val ? 1 : 0
			end
			
			def date_time
				Time.at(date)
			end
			
			def date_time=(val)
				date = val.to_i
			end
		end
	end
end