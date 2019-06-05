module ROM
  module Authentication
    Token = Struct.new(:type, :user, :login, :security_stamp)
  end
end