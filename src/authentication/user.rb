module ROM
  module Authentication
    User = Struct.new(:username, :security_stamp, :first_name, :last_name)
    end
end