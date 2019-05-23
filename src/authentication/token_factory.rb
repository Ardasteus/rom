module ROM
	class TokenFactory
	  include ROM::Component

		 def initiliaze(itc)
		 	@itc = itc
		 end

		 def issue_token(user, login, stamp)

		 end

		 def to_string(token)
		 end

		 def from_string(string)
		 end	
	end
end