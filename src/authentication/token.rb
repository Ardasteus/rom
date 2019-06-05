module ROM
  module Authentication
    Token = Struct.new(:type, :user, :login, :security_stamp, :expiry)
  end
end