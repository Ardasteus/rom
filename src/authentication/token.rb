module ROM
  module Authentication
    Token = Struct.new(:user, :login, :security_stamp)
  end
end